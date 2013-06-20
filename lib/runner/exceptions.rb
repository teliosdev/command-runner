module Runner

  # Raised when a path is instantized on a platform that doesn't
  # support it.
  class NotAvailablePathError < StandardError; end
end
