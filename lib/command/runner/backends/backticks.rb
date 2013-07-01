module Command
  class Runner
    module Backends

      # A backend that uses ticks to do its bidding.
      class Backticks < Fake

        # Returns whether or not this backend is avialable on this
        # platform.
        def self.available?
          true
        end

        # Initialize the fake backend.
        def initialize
          super
        end

        # Run the given command and arguments, in the given environment.
        #
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
          super
          output = ""
          start_time = nil
          end_time = nil

          with_modified_env(env) do
            start_time = Time.now
            output << `#{command} #{arguments}`
            end_time = Time.now
          end

          message = Message.new :process_id => $?.pid,
                      :exit_code => $?.exitstatus,
                      :finished => true,
                      :time => (end_time - start_time).abs,
                      :env => env,
                      :options => {},
                      :stdout => output,
                      :line => [command, arguments].join(' '),
                      :executed => true,
                      :status => $?

          if block_given?
            block.call(message)
          else
            message
          end
        end

        private

        # If ClimateControl is installed on this system, it runs the
        # given block with the given environment.  If it's not, it
        # just yields.
        #
        # @yield
        # @return [Object]
        def with_modified_env(env)
          if defined?(ClimateControl) || climate_control?
            ClimateControl.modify(env, &Proc.new)
          else
            yield
          end
        end

        # Checks to see if ClimateControl is on this system.
        #
        # @return [Boolean]
        def climate_control?
          begin
            require 'climate_control'
            true
          rescue LoadError
            false
          end
        end

      end
    end
  end

end
