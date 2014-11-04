module ZohoInvoice
  class CustomField < Base

    READ_ATTRIBUTES = [
      :index,
      :show_on_pdf,
      :value,
      :label
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES

    define_object_attrs(*READ_ATTRIBUTES)

  end
end