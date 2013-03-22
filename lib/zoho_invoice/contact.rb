require 'zoho_invoice/base'

module ZohoInvoice
  class Contact < Base

    define_object_attrs :salutation,
      :first_name,
      :last_name,
      :e_mail,
      :phone,
      :mobile

    def self.create(client, options = {})
      raise ZohoInvoice::ActionNotSupportedError
    end

    def save
      raise ZohoInvoice::ActionNotSupportedError
    end

  end
end
