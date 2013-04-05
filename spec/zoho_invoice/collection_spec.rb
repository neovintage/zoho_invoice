require 'spec_helper'

describe ZohoInvoice::Collection do

  before do
    @client = ZohoInvoice::Client.new
    @customers = ZohoInvoice::Collection.new(:customers, @client)
  end

  it "should correctly find the resource" do
    expect(@customers.resource ).to eq(:customers)
    expect(@customers.klass    ).to eq(ZohoInvoice::Customer)
    expect(@customers.client   ).to eq(@client)
  end

  it "should forward the initialize call to the underlying resource and pass the client" do
    customer = nil
    expect{ customer = @customers.new }.not_to raise_error
    expect(customer.class).to eq(ZohoInvoice::Customer)
    expect(customer.client).to eq(@client)

    expect{ customer = @customers.new(:name => 'Dude') }.not_to raise_error
    expect(customer.name).to eq('Dude')
    expect(customer.client).to eq(@client)
  end

  it "should forward the search call to the resource and pass the client" do
    ZohoInvoice::Customer.stub(:search)
    ZohoInvoice::Customer.should_receive(:search)
    expect{ @customers.search('find it') }.not_to raise_error
  end

  it "should forward the create method to the resource" do
    ZohoInvoice::Customer.stub(:create)
    ZohoInvoice::Customer.should_receive(:create)
    expect{ @customers.create(:name => 'Dude') }.not_to raise_error
  end

end
