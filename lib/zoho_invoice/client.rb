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

    def put(path, params={})
      request(:put, path, credentials.merge(params))
    end

    def request(verb, path, params={})
if params[:JSONString]
inv_json = {"invoice_id"=>'480266000000071007', "total"=>"0.0", "invoice_number"=>"INV-0010547", "balance"=>"0.0", "status"=>"paid", "notes"=>"Thanks for your business.", "customer_id"=>'480266000000071001', "terms"=>"Alex Test 4", "customer_name"=>"Alex Sherstinsky Test", "currency_code"=>"USD"}.to_json
puts("VERB=$#{verb}$ ; PARAMS_FOR_CONNECTION=$#{params}$")
end

if(:put == verb)
conn = connection
conn.post do |req|
req.url(path)
req.params = req.params.merge(credentials)
req.body = "{\"JSONString\":\"#{inv_json}\"}"
puts("VERB=$#{verb}$ ; EXECUTING=$#{req.params}$")
end
else
connection.send(verb, path, params)
end


      #connection.send(verb, path, params)
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
