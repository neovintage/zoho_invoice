require 'spec_helper'

describe ZohoInvoice do

  it "should be able to define global options on the module" do
    ZohoInvoice.configure do |config|
      config.authtoken = '11111'
      config.scope     = 'scope'
      config.apikey    = 'apikey'
      config.client_options = { :url => 'http://example.com' }
    end
    expect(ZohoInvoice.authtoken).to eq('11111')
    expect(ZohoInvoice.scope).to eq('scope')
    expect(ZohoInvoice.apikey).to eq('apikey')
    expect(ZohoInvoice.client_options).to eq({ :url => 'http://example.com' })
  end

  it "should be able to return its current options" do
    ZohoInvoice.configure do |config|
      config.authtoken = '22222'
    end
    expect(ZohoInvoice.config_hash[:authtoken]).to eq('22222')
  end
end
