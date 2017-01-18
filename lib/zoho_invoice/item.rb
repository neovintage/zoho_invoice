module ZohoInvoice
  class Item < Base

    READ_ATTRIBUTES = [
        :item_id,
        :name,
        :description,
        :tax_percentage,
        :tax_name,
        :rate,
        :status,
        :tax_id
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES - [:item_id]

    define_object_attrs(*READ_ATTRIBUTES)

    def self.create(client, options = {})
      raise ZohoInvoice::ActionNotSupportedError
    end

    def save
      raise ZohoInvoice::ActionNotSupportedError
    end

    def self.all(client) 
      retrieve(client, '/api/v3/items')
    end

  end
end