require 'zoho_invoice/base'

module ZohoInvoice
  class Contact < Base

    READ_ATTRIBUTES = [
        :contact_id,
        :contact_name,
        :company_name,
        :website,
        :currency_id,        
        :first_name,
        :last_name,
        :address,
        :email,
        :phone,
        :mobile,
        :contact_type,
        :billing_address,
        :shipping_address,
        :contact_persons,
        :notes,
        :created_time,
        :last_modified_time,
        :primary_contact_id,
        :payment_terms,
        :payment_terms_label,
        :status,
        :custom_fields
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES - [:contact_id]

    define_object_attrs(*READ_ATTRIBUTES)

    has_many :custom_fields


    def self.all(client) 
      retrieve(client, '/api/v3/contacts')
    end

    def self.find(client, id, options={})
      retrieve(client, "/api/v3/contacts/#{id}", false)
    end

  end
end
