require 'zoho_invoice/base'
require 'zoho_invoice/contact'

module ZohoInvoice
  class Customer < Base

    define_object_attrs :name,
      :payments_due,
      :currency_code,
      :billing_address,
      :billing_city,
      :billing_zip,
      :billing_country,
      :billing_fax,
      :shipping_address,
      :shipping_city,
      :shipping_state,
      :shipping_country,
      :shipping_fax,
      :customer_id,
      :active

    has_many :contacts

    def self.all(client, options = {})
      self.all_active(client, options) + self.all_inactive(client, options)
    end

    def self.all_active(client, options = {})
      retrieve(client, '/api/customers').each { |c| c.active = true }
    end

    def self.all_inactive(client, options = {})
      retrieve(client, '/api/customers/inactive').each { |c| c.active = false }
    end

  end
end
