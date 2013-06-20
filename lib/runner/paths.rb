module Runner

  # The different paths that the runner can take.  Each of them have a
  # different method of executing the process.
  module Paths

    autoload :Fake, "runner/paths/fake"
    autoload :Spawn, "runner/paths/spawn"
    autoload :PosixSpawn, "runner/paths/posix_spawn"

  end
end
