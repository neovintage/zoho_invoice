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
#test_json = {"notes" => "Thanks for your business.","customer_id" => "480266000000071001","terms" => "Alex Test 7"}.to_json
test_json = {"notes" => "Thanks for your business.","customer_id" => "480266000000071001","terms" => "Alex Test 7", "custom_fields" => [{"index" => "1","show_on_pdf" => "false","value" => "52605","label" => "Customer ID"},{"index" => "2","show_on_pdf" => "false","value" => "no","label" => "Renewal? (yes/no)"},{"index" => "3","show_on_pdf" => "false","value" => "true","label" => "Processed? (FOR ALEX ONLY)"}]}.to_json
puts("VERB=$#{verb}$ ; TEST_JSON=$#{test_json}$")
if(:put == verb)
connection.send(verb, path, credentials.merge({:JSONString => test_json}))
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
