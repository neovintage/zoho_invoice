module ZohoInvoice
  class Address < Base

    READ_ATTRIBUTES = [
        :address,
        :city,
        :state,
        :zip,
        :country,
        :fax
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES

    define_object_attrs(*READ_ATTRIBUTES)

  end
end