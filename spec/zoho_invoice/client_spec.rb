require 'spec_helper'

describe ZohoInvoice::Client do

  subject do
    ZohoInvoice::Client.new(default_credentials)
  end

  describe "#get" do
    it "can create custom requests" do
      query_hash = default_credentials.merge({:rad => 'object'})
      stub_get('/something/sweet').with(:query => query_hash)
      subject.get('/something/sweet', {:rad => 'object'})
      expect(a_get('/something/sweet').with(:query => query_hash)).to have_been_made
    end
  end

  describe "#post" do
    it "can create custom requests" do
      query_hash = default_credentials.merge({:rad => 'object'})
      stub_post('/something/awesome').with(:body => query_hash)
      subject.post('/something/awesome', {:rad => 'object'})
      expect(a_post('/something/awesome').with(:body => query_hash)).to have_been_made
    end
  end

  describe "#request" do
    it "can create custom requests" do
      stub_post('/awesome').with(:body => {:rad => 'object'})
      subject.request(:post, '/awesome', {:rad => 'object'})
      expect(a_post('/awesome').with({:rad => 'object'})).to have_been_made
    end

    it "does not include default credentials in params" do
      stub_get('/awesome')
      subject.request(:get, '/awesome')
      expect(a_get('/awesome')).to have_been_made
    end
  end

  describe "initialization" do
    it "can pass options to faraday" do
      client = ZohoInvoice::Client.new(
        default_credentials.merge({
          :client_options => {
            :url => 'http://something.com'
          }
        })
      )
      stub_request(:get, 'http://something.com/awesome').with(:query => default_credentials)
      client.get('/awesome')
      expect(a_request(:get, 'http://something.com/awesome').with(:query => default_credentials)).to have_been_made
    end

    it "will inherit config from defaults" do
      client = ZohoInvoice::Client.new
      expect(client.scope).to eq(ZohoInvoice::Defaults::SCOPE)
      expect(client.client_options).to eq({ :url => ZohoInvoice::Defaults::URL })
    end
  end

end
