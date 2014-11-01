require 'zoho_invoice/base'

module ZohoInvoice
  class Contact < Base

    READ_ATTRIBUTES = [
        :contact_id,
        :contact_name,
        :company_name,
        :first_name,
        :last_name,
        :address,
        :email,
        :phone,
        :mobile
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES - [:contact_id]

    define_object_attrs(*READ_ATTRIBUTES)

    def self.all(client)
      retrieve(client, '/api/v3/contacts')
    end

    def self.find(client, id, options={})
      retrieve(client, "/api/v3/contacts/#{id}", false)
    end

  end
end
