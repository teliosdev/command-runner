module Command
  class Runner

    # This contains information about the process that was run, such as
    # its exit code, process id, and even time it took to run.
    class Message

      # Initialize the message with the given data about the process.
      #
      # @param data [Hash] the data about the process.
      # @option data [Numeric] :exit_code (0) the code the process
      #   exited with.
      # @option data [Numeric] :process_id (-1) the process id the
      #   process ran under.
      # @option data [Numeric] :time (0) the amount of time the
      #   process took to run, in seconds.
      # @option data [Boolean] :executed (false) whether or not the
      #   process was actually executed.
      # @option data [Hash] :env ({}) the environment the process
      #   ran under.
      # @option data [Hash] :options ({}) the options that the process
      #   was run under.
      # @option data [String] :stdout ("\n") the output the command
      #   outputted on stdout.  This does not include output on stderr.
      # @option data [String] :stderr ("") the output the command
      #   outputted on stderr.  This does not include output on stdout.
      # @option data [String] :line ("") the line that was executed.
      # @option data [Process::Status] :status (nil) the status of the
      #   process.
      def initialize(data)
        {
          :executed   => false,
          :time       => 0,
          :process_id => -1,
          :exit_code  => 0,
          :env        => {},
          :options    => {},
          :stdout     => "\n",
          :stderr     => "",
          :line       => "",
          :status     => nil
        }.merge(data).each do |k, v|
          instance_variable_set(:"@#{k}", (v.dup rescue v))
        end
      end

      # Whether or not the process was actually executed.
      #
      # @return [Boolean]
      def executed?
        @executed
      end

      # Whether or not the exit code was non-zero.
      #
      # @return [Boolean]
      def nonzero_exit?
        exit_code != 0
      end

      # @!attribute [r] exit_code
      #   The code the process exited with.
      #
      #   @return [Numeric]
      # @!attribute [r] process_id
      #   The process id the process ran under.
      #
      #   @return [Numeric]
      # @!attribute [r] time
      #   The amount of time the process took to run, in seconds.
      #
      #   @return [Numeric]
      # @!attribute [r] stdout
      #   The standard out of the process that was executed.
      #
      #   @return [String]
      # @!attribute [r] stderr
      #   The standard error of the process that was executed.
      #
      #   @return [String]
      # @!attribute [r] options
      #   The options that the user passed when executing the process.
      #
      #   @return [Hash]
      # @!attribute [r] line
      #   The exact line that was executed.
      #
      #   @return [String]
      # @!attribute [r] status
      #   The status of the process.
      #
      #   @return [Process::Status]
      [:exit_code, :process_id, :time, :stdout, :stderr, :options,
        :line, :status].each do |key|
        define_method(key) { instance_variable_get(:"@#{key}") }
      end


    end
  end
end
