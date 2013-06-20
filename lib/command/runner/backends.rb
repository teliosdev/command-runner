module Command

  class Runner

    # The different backends that the runner can take.  Each of them have a
    # different method of executing the process.
    module Backends

      autoload :Fake, "command/runner/backends/fake"
      autoload :Spawn, "command/runner/backends/spawn"
      autoload :Backticks, "command/runner/backends/backticks"
      autoload :PosixSpawn, "command/runner/backends/posix_spawn"

    end

  end
end
