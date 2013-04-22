require 'zoho_invoice/error'

module ZohoInvoice
  class Error
    class ClientError < ZohoInvoice::Error

      def self.from_response(response={})
        self.parse_error(response)
      end

      private

      def self.parse_error(response)
        error = self.new
        if !response[:body].nil?
          response_body = response[:body]
          error.response_status  = response_body['Response']['status']
          error.code    = response_body['Response']['Code']
          error.message = response_body['Response']['Message']
        end
        error.http_status = response[:status]
        error
      end

    end
  end
end

