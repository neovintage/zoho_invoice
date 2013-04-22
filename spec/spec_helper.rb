# Get everything loaded up per gemspec
#
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'rspec'
require 'zoho_invoice'
require 'webmock/rspec'
require 'pry'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end

def invoice_test(path, fixture_to_use, num_invoices, match_regex, method_to_test, *args)
  stub_get(path).
    with(:query => default_credentials).
    to_return(:status => 200, :body => fixture(fixture_to_use), :headers => {:content_type => 'application/xml'})
  result = ZohoInvoice::Invoice.send(method_to_test, args[0], args[1])
  expect(a_get(path).with(:query => default_credentials)).to have_been_made
  expect(result.class).to eq(Array)
  expect(result.length).to eq(num_invoices)
  if num_invoices > 0
    result.each_with_index do |r, i|
      expect(r.class).to eq(ZohoInvoice::Invoice)
      expect(r.invoice_id).to eq((i+1).to_s)
      expect(r.status).to match(match_regex)
    end
  end
end

def multiple_invoice_test(fixture_to_use, num_customers, method_to_test, method_to_stub, *args)
  ZohoInvoice::Invoice.stub(method_to_stub).and_return([{'InvoiceID' => 1, 'CustomerName' => 'SampleName', 'Status' => 'Open', 'InvoiceDate' => 'January 1, 2013', 'Balance' => '$299.99'}])

  result = ZohoInvoice::Invoice.send(method_to_test, args[0], args[1])
  expect(result.class).to eq(Hash)
  expect(result.length).to eq(num_customers)
  if num_customers > 0
    args[1].each do |id|
      customer = result[id]
      expect(customer.class).to eq(Array)
    end
  end
end

def error_test(path, fixture_to_use, method_to_test, message, code, response_status, http_status, *args)
  stub_get(path).
    with(:query => default_credentials).
    to_return(:status => 500, :body => fixture(fixture_to_use), :headers => { :content_type => 'application/xml' })
  expect { ZohoInvoice::Invoice.send(method_to_test, args[0], args[1]) }.to raise_error { |e|
    error_expectations(e, message, code, response_status, http_status)
  }
  expect(a_get(path).with(query: default_credentials)).to have_been_made
end

def error_expectations(object, message, code, response_status, http_status)
  expect(object.class).to eq(ZohoInvoice::Error::ClientError)
  expect(object.message).to eq(message)
  expect(object.code).to eq(code)
  expect(object.response_status).to eq(response_status)
  expect(object.http_status).to eq(http_status)
end

def stub_get(path)
  stub_request(:get, ZohoInvoice::Defaults::URL + path)
end

def a_get(path)
  a_request(:get, ZohoInvoice::Defaults::URL + path)
end

def stub_post(path)
  stub_request(:post, ZohoInvoice::Defaults::URL + path)
end

def a_post(path)
  a_request(:post, ZohoInvoice::Defaults::URL + path)
end

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def default_credentials
  {
    :authtoken => '1234',
    :scope     => ZohoInvoice::Defaults::SCOPE,
    :apikey    => '5678'
  }
end
