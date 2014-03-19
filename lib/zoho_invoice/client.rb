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
      if(:post === verb)
puts("PARAMS_FOR_POST_CONNECTION=$#{params}$")
        connection.post do |request|
          request.url(path)
          request.headers['Content-Type'] = 'application/json'
puts("PARAMS_JSON_FOR_POST_CONNECTION=$#{params.to_json}$")
          request.body = params.to_json
        end
      else
        connection.send(verb, path, params)
      end
    end

    private

    def connection
      @connection ||= Faraday.new(@client_options) do |c|
        c.use       Faraday::Response::RaiseError

        c.request :multipart
        c.request :url_encoded

        #<AlexSherstinsky>The V3 Zoho API version returns data in the JSON format.</AlexSherstinsky>
        #c.response  :xml, :content_type => /\bxml$/
        c.response  :json, :content_type => /\bjson$/

        c.adapter Faraday.default_adapter
      end
    end

  end
end
