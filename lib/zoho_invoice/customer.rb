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
      :customer_id

    has_many :contacts

    def self.search(client, input_text)
    end

  end
end
