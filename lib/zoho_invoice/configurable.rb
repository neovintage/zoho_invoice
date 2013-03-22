require 'forwardable'

module ZohoInvoice
  module Configurable
    extend Forwardable

    # @return [String] The permanent authtoken used to authenticate each API request
    attr_accessor :authtoken

    # @return [String] The value for this parameter has to be invoiceapi
    attr_accessor :scope

    # @return [String] The key used to authenticate the API caller
    attr_accessor :apikey

    # @return [Hash] Client configuration to pass to Faraday
    attr_accessor :client_options

    # Just a helper to identify the options to pass in for configuration
    #
    def_delegator :options, :hash

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

    private

    def credentials
      {
        :authtoken => @authtoken,
        :scope     => @scope,
        :apikey    => @apikey
      }
    end

    def options
      Hash[ZohoInvoice::Configurable.keys.map{ |key| [key, instance_variable_get(:"@#{key}")] }]
    end
  end
end
