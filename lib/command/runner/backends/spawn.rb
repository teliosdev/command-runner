module Command
  class Runner
    module Backends

      # Spawns a process using ruby's Process.spawn.
      class Spawn < Fake

        # (see Fake.available?)
        def self.available?
          Process.respond_to?(:spawn)
        end

        # Initialize the backend.
        def initialize
          super
        end

        # Run the given command and arguments, in the given environment.
        #
        # @param (see Fake#call)
        # @return (see Fake#call)
        def call(command, arguments, env = {}, options = {})
          super
          stderr_r, stderr_w = IO.pipe
          stdout_r, stdout_w = IO.pipe
          stdin_r,  stdin_w  = IO.pipe

          new_options = options.merge(in: stdin_r, out: stdout_w, err: stderr_w)

          if new_options[:input]
            stdin_w.write(new_options.delete(:input))
          end
          stdin_w.close

          line = [command, arguments].join(' ')

          start = Time.now
          process_id = spawn(env, line, new_options)

          future do
            _, status = wait2(process_id)
            end_time = Time.now

            [stdout_w, stderr_w].each(&:close)

            Message.new process_id: process_id,
              exit_code: status.exitstatus, finished: true,
              time: (start - end_time).abs, env: env,
              options: options, stdout: stdout_r.read,
              stderr: stderr_r.read, line: line,
              executed: true, status: status
          end

        rescue Errno::ENOENT => e
          Message.new exit_code: 127, finished: true, time: -1,
          env: {}, options: {}, stdout: "", stderr: e.message,
          line: line, executed: false
        end

        # Spawn the given process, in the environment with the
        # given options.
        #
        # @see Process.spawn
        # @return [Numeric] the process id
        def spawn(env, line, options)
          Process.spawn(env, line, options)
        end

        # Waits for the given process, and returns the process id and the
        # status.
        #
        # @see Process.wait2
        # @return [Array<(Numeric, Process::Status)>]
        def wait2(process_id = -1)
          Process.wait2(process_id)
        end

      end

    end
  end
end
