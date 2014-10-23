require 'faraday'
require 'faraday_middleware'
require 'nokogiri'
require 'multi_xml'

require 'zoho_invoice/core_ext/string'
require 'zoho_invoice/error'
require 'zoho_invoice/error/client_error'

require 'zoho_invoice/configurable'
require 'zoho_invoice/auth_token'
require 'zoho_invoice/defaults'

require 'zoho_invoice/client'
require 'zoho_invoice/version'
require 'zoho_invoice/base'
require 'zoho_invoice/customer'
require 'zoho_invoice/item'
require 'zoho_invoice/line_item'
require 'zoho_invoice/invoice'

module ZohoInvoice
  class << self
    include ZohoInvoice::Configurable
  end

  # Default for connecting to Zoho Invoice API
  #
  @client_options = {
    :url => ZohoInvoice::Defaults::URL
  }

  @scope = ZohoInvoice::Defaults::SCOPE

end
