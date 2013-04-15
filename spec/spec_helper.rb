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
