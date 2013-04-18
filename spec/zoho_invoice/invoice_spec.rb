require 'spec_helper'

describe ZohoInvoice::Invoice do

  describe "searching by customer" do
    before do
      @client = ZohoInvoice::Client.new(default_credentials)
    end

    it "should return an array if a customer has a single invoice" do
      stub_get('/api/view/invoices/customer/1234').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_single_customer_response'), :headers => {:content_type => 'application/xml'})
      result = ZohoInvoice::Invoice.find_by_customer_id(@client, '1234')
      expect(a_get('/api/view/invoices/customer/1234').with(query: default_credentials)).to have_been_made
      expect(result.class).to eq(Array)
      expect(result.length).to eq(1)
      result.each_with_index do |r, i|
        expect(r.class).to eq(ZohoInvoice::Invoice)
        expect(r.invoice_id).to eq((i+1).to_s)
        expect(r.status).to match(/Draft|Open|Closed|Overdue|Void/)
      end
    end

    it "should return an array if a customer has multiple invoices" do
      stub_get('/api/view/invoices/customer/1234').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_multiple_customer_response'), :headers => {:content_type => 'application/xml'})
      result = ZohoInvoice::Invoice.find_by_customer_id(@client, '1234')
      expect(a_get('/api/view/invoices/customer/1234').with(query: default_credentials)).to have_been_made
      expect(result.class).to eq(Array)
      expect(result.length).to eq(2)
      result.each_with_index do |r, i|
        expect(r.class).to eq(ZohoInvoice::Invoice)
        expect(r.invoice_id).to eq((i+1).to_s)
        expect(r.status).to match(/Draft|Open|Closed|Overdue|Void/)
      end
    end

    it "should return an empty array if a customer doesn't have any invoices" do
      stub_get('/api/view/invoices/customer/1234').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_empty_customer_response'), :headers => {:content_type => 'application/xml'})
      result = ZohoInvoice::Invoice.find_by_customer_id(@client, '1234')
      expect(a_get('/api/view/invoices/customer/1234').with(query: default_credentials)).to have_been_made
      expect(result.class).to eq(Array)
      expect(result.length).to eq(0)
    end

    # TODO Needs to change because you'll have no idea an error happened
    #
    #it "should return an empty array if theres an error" do
    #  body_params = default_credentials.merge(:searchtext => '1234')
    #  stub_get('/api/view/search/somethings').
    #    with(:query => body_params).
    #    to_return(:status => 500)
    #  result = Something.search(@client, '1234')
    #  expect(a_get('/api/view/search/somethings').with(query: body_params)).to have_been_made
    #  expect(result.class).to eq(Array)
    #  expect(result.length).to eq(0)
    #end
  end

  describe "searching by customer (unpaid)" do
    before do
      @client = ZohoInvoice::Client.new(default_credentials)
    end

    it "should return an array if a customer has a single unpaid invoice" do
      stub_get('/api/view/invoices/unpaid/customer/1234').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_unpaid_single_customer_response'), :headers => {:content_type => 'application/xml'})
      result = ZohoInvoice::Invoice.find_unpaid_by_customer_id(@client, '1234')
      expect(a_get('/api/view/invoices/unpaid/customer/1234').with(query: default_credentials)).to have_been_made
      expect(result.class).to eq(Array)
      expect(result.length).to eq(1)
      result.each_with_index do |r, i|
        expect(r.class).to eq(ZohoInvoice::Invoice)
        expect(r.invoice_id).to eq((i+1).to_s)
        expect(r.status).to match(/Open|Overdue/)
      end
    end

    it "should return an array if a customer has multiple unpaid invoices" do
      stub_get('/api/view/invoices/unpaid/customer/1234').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_unpaid_multiple_customer_response'), :headers => {:content_type => 'application/xml'})
      result = ZohoInvoice::Invoice.find_unpaid_by_customer_id(@client, '1234')
      expect(a_get('/api/view/invoices/unpaid/customer/1234').with(query: default_credentials)).to have_been_made
      expect(result.class).to eq(Array)
      expect(result.length).to eq(2)
      result.each_with_index do |r, i|
        expect(r.class).to eq(ZohoInvoice::Invoice)
        expect(r.invoice_id).to eq((i+1).to_s)
        expect(r.status).to match(/Open|Overdue/)
      end
    end

    it "should return an empty array if a customer doesn't have any unpaid invoices" do
      stub_get('/api/view/invoices/unpaid/customer/1234').
        with(:query => default_credentials).
        to_return(:status => 200, :body => fixture('successful_unpaid_empty_customer_response'), :headers => {:content_type => 'application/xml'})
      result = ZohoInvoice::Invoice.find_unpaid_by_customer_id(@client, '1234')
      expect(a_get('/api/view/invoices/unpaid/customer/1234').with(query: default_credentials)).to have_been_made
      expect(result.class).to eq(Array)
      expect(result.length).to eq(0)
    end

    # TODO Needs to change because you'll have no idea an error happened
    #
    #it "should return an empty array if theres an error" do
    #  body_params = default_credentials.merge(:searchtext => '1234')
    #  stub_get('/api/view/search/somethings').
    #    with(:query => body_params).
    #    to_return(:status => 500)
    #  result = Something.search(@client, '1234')
    #  expect(a_get('/api/view/search/somethings').with(query: body_params)).to have_been_made
    #  expect(result.class).to eq(Array)
    #  expect(result.length).to eq(0)
    #end
  end


end
