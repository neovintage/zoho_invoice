require 'zoho_invoice/collection'

module ZohoInvoice
  class Client
    include ZohoInvoice::Configurable

    RESOURCES = [
      :customers,
      :invoices
    ]

    RESOURCES.each do |resource|
      define_method(resource, ->{ ZohoInvoice::Collection.new(resource, self) })
    end

    def initialize(options = {})
      ZohoInvoice::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || ZohoInvoice.instance_variable_get(:"@#{key}"))
      end
      @client_options = ZohoInvoice.instance_variable_get(:'@client_options').merge(options[:client_options] || {})
    end

    def get(path, params={})
      request(:get, path, credentials.merge(params))
    end

    def post(path, params={})
      request(:post, path, credentials.merge(params))
    end

    def request(verb, path, params={})
      connection.send(verb, path, params)
    end

    private

    def connection
      @connection ||= Faraday.new(@client_options) do |c|
        c.use       Faraday::Response::RaiseError
        c.response  :xml, :content_type => 'application/xml'

        c.request :multipart
        c.request :url_encoded

        c.adapter Faraday.default_adapter
      end
    end

  end
end
