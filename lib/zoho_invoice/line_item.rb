module ZohoInvoice
  class LineItem < Base

    READ_ATTRIBUTES = [
        :item_id,
        :project_id,
        :name,
        :description,
        :item_order,
        :unit,
        :rate,
        :quantity,
        :discount,
        :tax_id
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES - [:item_id]

    define_object_attrs(*READ_ATTRIBUTES)

  end
end



