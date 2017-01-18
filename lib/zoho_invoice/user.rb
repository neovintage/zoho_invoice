require 'zoho_invoice/base'

module ZohoInvoice
  class User < Base

    define_object_attrs :user_id,
                        :role_id,
                        :name,
                        :email,
                        :user_role,
                        :status,
                        :is_current_user,
                        :photo_url,
                        :is_customer_segmented,
                        :is_vendor_segmented,
                        :role_id,


    def self.all(client, options = {})
      retrieve(client, '/api/v3/users')
    end

    def self.find(client, id, options={})
      retrieve(client, "/api/v3/users/#{id}", false)
    end
  end
end
