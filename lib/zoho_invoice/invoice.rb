require 'zoho_invoice/invoice_item'

module ZohoInvoice
  class Invoice < Base

    define_object_attrs :invoice_id,
      :created_time,          :exchange_rate,
      :last_modified_time,    :l_f_name,
      :last_sync_time,        :late_fee_amount,
      :source,                :total,
      :reference_id,          :invoice_item_total,
      :invoice_number,        :tax_total,
      :p_o_number,            :balance,
      :status,
      :customer_id,
      :customer_name,
      :invoice_date,
      :payments_due,
      :due_date,
      :currency_code

    has_many :invoice_items

    def self.find_by_customer_id(client, id, options = {})
      result_hash = client.get("/api/view/invoices/customer/#{id}").body
      objects_to_hydrate = result_hash['Response']["Invoices"]["Invoice"]
      self.process_objects(client, objects_to_hydrate)
    rescue Faraday::Error::ClientError => e
      return []
    end

  end
end
