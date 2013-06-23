module Command

  class Runner

    # Raised when a backend is instantized on a platform that doesn't
    # support it.
    class NotAvailableBackendError < StandardError; end

    # Raised when a command that was passed is not available on this
    # platform.
    class NoCommandError < StandardError; end

  end
end
