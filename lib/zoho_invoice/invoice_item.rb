require 'zoho_invoice/item'

module ZohoInvoice
  class InvoiceItem < Base

    define_object_attrs :item_name,
      :item_description,
      :price,
      :quantity,
      :discount

  end
end
