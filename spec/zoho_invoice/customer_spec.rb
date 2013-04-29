require 'spec_helper'

describe ZohoInvoice::Customer do
  describe "retrieving customers" do
    before do
      @client = ZohoInvoice::Client.new(default_credentials)
    end

    it "should return an array of active customers" do
      customer_test('/api/customers', 'successful_customers_response', 1, true, :all_active, @client)
    end

    it "should return an array of inactive customers" do
      customer_test('/api/customers/inactive', 'successful_customers_response', 1, false, :all_inactive, @client)
    end

    it "should return an array of all customers" do
      stub_get('/api/customers').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_customers_response'), :headers => {:content_type => 'application/xml'})

      stub_get('/api/customers/inactive').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_customers_response'), :headers => {:content_type => 'application/xml'})

      result = ZohoInvoice::Customer.send('all', @client)
      expect(a_get('/api/customers').with(:query => default_credentials)).to have_been_made
      expect(a_get('/api/customers/inactive').with(:query => default_credentials)).to have_been_made
      expect(result.class).to eq(Array)
      expect(result.length).to eq(2)

      result.each_with_index do |r, i|
        expect(r.class).to eq(ZohoInvoice::Customer)
        expect(r.active.to_s).to match(/true|false/)
      end
    end
  end
end
