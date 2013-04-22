module ZohoInvoice
  class Error < StandardError

    attr_accessor :message, :code, :response_status, :http_status
  end
end
