module Command
  class Runner
    module Backends

      # SSHs into a remote and runs commands there.
      #
      # @note The message that is returned by this may not be entirely
      #    filled with data, since some of it may not be able to be
      #    accessible.
      class SSH < Fake

        # (see Fake.available?)
        def self.available?
          begin
            require 'net/ssh'
            true
          rescue LoadError
            false
          end
        end

        # Initializes the backend.
        #
        # @param host [String] the host to connect to.
        # @param user [String] the user to log in as.
        # @param options [Hash] the options to pass to Net::SSH.
        def initialize(host, user, options = {})
          super()
          @net_ssh = Net::SSH.start(host, user, options)
        end

        # (see Spawn#call)
        def call(command, arguments, env = {}, options = {}, &block)
          super
          mdata   = { :stdout => "", :stderr => "", :env => env, :options => {} }
          channel = @net_ssh.open_channel do |ch|


            ch.exec "#{command} #{arguments}" do |sch, success|
              raise Errno::ENOENT unless success

              env.each do |k, v|
                sch.env k.to_s, v
              end

              sch.on_data do |_, data|
                mdata[:stdout] << data
              end

              sch.on_extended_data do |_, type, data|
                mdata[:stderr] << data if type == 1
              end

              sch.on_request "exit-status" do |_, data|
                mdata[:exit_code] = data.read_long
              end

              sch.on_close do
                mdata[:executed] = true
                mdata[:finished] = true
              end

            end
          end

          future do
            start_time = Time.now
            channel.wait
            end_time   = Time.now
            channel.close

            mdata[:time] = (end_time - start_time).abs

            message = Message.new mdata

            if block_given?
              block.call(message)
            else
              message
            end
          end
        end

      end
    end
  end
end
