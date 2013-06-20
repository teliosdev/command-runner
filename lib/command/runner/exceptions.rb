module Command

  class Runner

    # Raised when a backend is instantized on a platform that doesn't
    # support it.
    class NotAvailableBackendError < StandardError; end

  end
end
