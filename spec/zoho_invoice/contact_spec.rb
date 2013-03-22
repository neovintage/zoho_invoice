require 'spec_helper'

describe ZohoInvoice::Contact do

  before do
    @client = ZohoInvoice::Client.new(default_credentials)
  end

  it ".create should raise an error" do
    expect{ ZohoInvoice::Contact.create(@client) }.to raise_error(ZohoInvoice::ActionNotSupportedError)
  end

  it "#save should raise an error" do
    contact = ZohoInvoice::Contact.new(@client)
    expect{ contact.save }.to raise_error(ZohoInvoice::ActionNotSupportedError)
  end

end
