require 'shellwords'
require 'future'

require 'command/runner/version'
require 'command/runner/message'
require 'command/runner/exceptions'
require 'command/runner/backends'

module Command

  # This handles the execution of commands.
  class Runner

    class << self
      # Gets the default backend to use with the messenger.
      # Defaults to the best available backend.
      #
      # @return [#call] a backend to use.
      def backend
        @backend ||= best_backend
      end

      # Returns the best backend for messenger to use.
      #
      # @return [#call] a backend to use.
      def best_backend(force_unsafe = false)
        if Backends::PosixSpawn.available? && !force_unsafe
          Backends::PosixSpawn.new
        elsif Backends::Spawn.available? && !force_unsafe
          Backends::Spawn.new
        elsif Backends::Backticks.available?
          Backends::Backticks.new
        else
          Backends::Fake.new
        end
      end

      # Sets the default backend to use with the messenger.
      attr_writer :backend
    end

    # The command the messenger was initialized with.
    #
    # @return [String]
    attr_reader :command

    # The arguments the messenger was initialized with.
    #
    # @return [String]
    attr_reader :arguments

    # The options the messenger was initialized with.
    #
    # @return [Hash]
    # @!parse
    #   attr_reader :options
    def options
      @options.dup.freeze
    end

    # Gets the backend to be used by the messenger.  If it is not defined
    # on the instance, it'll get the class default.
    #
    # @see Runner.backend
    # @return [#call] a backend to use.
    def backend
      @backend || self.class.backend
    end

    # Sets the backend to be used by the messenger.  This is local to the
    # instance.
    attr_writer :backend

    # Initialize the messenger.
    #
    # @param command [String] the name of the command file to run.
    # @param arguments [String] the arguments to pass to the command.
    #   may contain interpolated values, like +{key}+ or +{{key}}+.
    # @param options [Hash] the options for the messenger.
    def initialize(command, arguments, options = {})
      @command = command
      @arguments = arguments
      @options = options
    end

    # Runs the command and arguments with the given interpolations;
    # defaults to no interpolations.
    #
    # @note This method may not raise a {NoCommandError} and instead
    #   return a {Message} with the error code +127+, even if the
    #   command doesn't exist.
    # @yield [Message] when the command finishes.
    # @raise [NoCommandError] on no command.
    # @param interops [Hash<Symbol, Object>] the interpolations to
    #   make.
    # @param options [Hash<Symbol, Object>] the options for the
    #   backend.
    # @return [Message, Object] message if no block was given, the
    #   return value of the block otherwise.
    def pass!(interops = {}, options = {}, &block)
      backend.call(*[*contents(interops), options.delete(:env) || {}, options], &block)

    rescue Errno::ENOENT
      raise NoCommandError, @command
    end

    alias_method :run!, :pass!

    # Runs the command and arguments with the given interpolations;
    # defaults to no interpolations.  Calls {#pass!}, but does not
    # raise an error.
    #
    # @yield (see #pass!)
    # @param (see #pass!)
    # @return (see #pass!)
    def pass(interops = {}, options = {}, &block)
      pass! interops, options, &block

    rescue NoCommandError
      message = Message.error(contents(interops).join(' '))

      if block_given?
        block.call(message)
      else
        message
      end
    end

    alias_method :run, :pass

    # Whether or not to force an unsafe backend.  This should only be
    # used in cases where the developer wants the arguments passed to
    # a shell, so that the unsafe interpolated arguments can be
    # shell'd.
    #
    # @return [void]
    def force_unsafe!
      @backend = self.class.best_backend(true)
    end

    # The command line being run by the runner. Interpolates the
    # arguments with the given interpolations.
    #
    # @see #interpolate
    # @param interops [Hash] the interpolations to make.
    # @return [Array<(String, String)>] the command line that will be run.
    def contents(interops = {})
      [command, interpolate(arguments, interops)]
    end

    # Interpolates the given string with the given interpolations.
    # The keys of the interpolations should be alphanumeric,
    # including underscores and dashes.  It will search the given
    # string for +{key}+ and +{{key}}+; if it finds the former, it
    # replaces it with the escaped value.  If it finds the latter, it
    # replaces it with the value directly.
    #
    # @param string [String] the string to interpolate.
    # @param interops [Hash] the interpolations to make.
    # @return [Array<String>] the interpolated string.
    def interpolate(string, interops = {})
      interops = interops.to_a.map { |(k, v)| { k.to_s => v } }.inject(&:merge) || {}
      results = [*string.shellsplit]

      results.map do |part|
        if part =~ /(\{{1,2})([0-9a-zA-Z_\-]+)(\}{1,2})/
          if interops.key?($2) && $1.length == $3.length
            if $1.length == 1
              escape interops[$2].to_s
            else
              interops[$2].to_s.shellsplit
            end
          else
            part
          end
        else
          part
        end
      end.flatten
    end

    private

    # Escape the given string for a shell if the backend is unsafe,
    # otherwise it just returns the string.
    #
    # @param string [String] the string to escape.
    # @return [String] the escaped string.
    def escape(string)
      if backend.unsafe?
        Shellwords.escape(string)
      else
        string
      end
    end

  end
end
