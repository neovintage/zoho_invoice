require 'spec_helper'

describe ZohoInvoice::Invoice do

  describe "searching by customer" do
    before do
      @client = ZohoInvoice::Client.new(default_credentials)
    end

    it "should return an array if a customer has a single invoice" do
      invoice_test('/api/view/invoices/customer/1234', 'successful_single_customer_response', 1, /Draft|Open|Closed|Overdue|Void/, :find_by_customer_id, @client, '1234')
    end

    it "should return an array if a customer has multiple invoices" do
      invoice_test('/api/view/invoices/customer/1234', 'successful_multiple_customer_response', 2, /Draft|Open|Closed|Overdue|Void/, :find_by_customer_id, @client, '1234')
    end

    it "should return an empty array if a customer doesn't have any invoices" do
      invoice_test('/api/view/invoices/customer/1234', 'successful_empty_customer_response', 0, //, :find_by_customer_id, @client, '1234')
    end

    it "should return an error if theres an error" do
      error_test('/api/view/invoices/customer/1234', '500_internal_server_error', :find_by_customer_id, 'Invalid value passed for XMLString', '2', '0', 500, @client, '1234')
    end

    it "should return a hash if multiple customers are searched for" do
      multiple_invoice_test('invoice_array', 2, :find_by_multiple_customer_ids, :find_by_customer_id, @client, [1234, 5678])
    end
  end

  describe "searching by customer (unpaid)" do
    before do
      @client = ZohoInvoice::Client.new(default_credentials)
    end

    it "should return an array if a customer has a single unpaid invoice" do
      invoice_test('/api/view/invoices/unpaid/customer/1234', 'successful_unpaid_single_customer_response', 1, /Open|Overdue/, :find_unpaid_by_customer_id, @client, '1234')
    end

    it "should return an array if a customer has multiple unpaid invoices" do
      invoice_test('/api/view/invoices/unpaid/customer/1234', 'successful_unpaid_multiple_customer_response', 2, /Open|Overdue/, :find_unpaid_by_customer_id, @client, '1234')
    end

    it "should return an empty array if a customer doesn't have any unpaid invoices" do
      invoice_test('/api/view/invoices/unpaid/customer/1234', 'successful_unpaid_empty_customer_response', 0, //, :find_unpaid_by_customer_id, @client, '1234')
    end

    it "should return an error if theres an error" do
      error_test('/api/view/invoices/unpaid/customer/1234', '500_internal_server_error', :find_unpaid_by_customer_id, 'Invalid value passed for XMLString', '2', '0', 500, @client, '1234')
    end

     it "should return a hash if multiple customers are searched for" do
      multiple_invoice_test('invoice_array', 2, :find_unpaid_by_multiple_customer_ids, :find_unpaid_by_customer_id, @client, [1234, 5678])
    end
  end

end
