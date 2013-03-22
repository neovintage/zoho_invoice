module ZohoInvoice
  module Configurable

    # @return [String] The permanent authtoken used to authenticate each API request
    attr_accessor :authtoken

    # @return [String] The value for this parameter has to be invoiceapi
    attr_accessor :scope

    # @return [String] The key used to authenticate the API caller
    attr_accessor :apikey

    # @return [Hash] Client configuration to pass to Faraday
    attr_accessor :client_options

    class << self

      def keys
        @keys ||= [
          :authtoken,
          :scope,
          :apikey,
          :client_options
        ]
      end

    end

    def configure
      yield self
      self
    end

    def config_hash
      Hash[ZohoInvoice::Configurable.keys.map{ |key| [key, instance_variable_get(:"@#{key}")] }]
    end

    private

    def credentials
      {
        :authtoken => @authtoken,
        :scope     => @scope,
        :apikey    => @apikey
      }
    end

  end
end
