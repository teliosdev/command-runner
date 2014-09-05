module Command
  class Runner
    module Backends
      class UnsafeFake < Fake

        # A backend is considered unsafe when the arguments are
        # exposed directly to the shell.  This is a vulnerability, so
        # we mark the class as unsafe and when we're about to pass
        # the arguments to the backend, escape the safe
        # interpolations.
        #
        # @return [Boolean]
        def self.unsafe?
          true
        end
      end
    end
  end
end
