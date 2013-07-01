module Command
  class Runner
    module Backends

      # A fake backend.  Used to a) define what backends should respond
      # to, and b) provide default behavior for the backends.
      #
      # @abstract
      class Fake

        # Returns whether or not this backend is avialable on this
        # platform.
        #
        # @abstract
        def self.available?
          true
        end

        # Initialize the fake backend.
        def initialize
          @ran = []

          raise NotAvailableBackendError unless self.class.available?
        end

        # Run the given command and arguments, in the given environment.
        #
        # @abstract
        # @note Does nothing.
        # @raise [Errno::ENOENT] if the command doesn't exist.
        # @yield [Message] when the command finishes.
        # @param command [String] the command to run.
        # @param arguments [String] the arguments to pass to the
        #   command.
        # @param env [Hash] the enviornment to run the command
        #   under.
        # @param options [Hash] the options to run the command under.
        # @return [Message, Object] message if no block is given, the
        #   result of the block call otherwise.
        def call(command, arguments, env = {}, options = {}, &block)
          @ran << [command, arguments]

          message = Message.new :env => env, :options => options, :line =>
            [command, arguments].join(' ')
        end

        # Determines whether or not the given command and arguments were
        # ran with this backend.
        #
        # @see #call
        # @param command [String]
        # @param arguments [String]
        # @return [Boolean]
        def ran?(command, arguments)
          @ran.include?([command, arguments])
        end

      end
    end
  end

end
