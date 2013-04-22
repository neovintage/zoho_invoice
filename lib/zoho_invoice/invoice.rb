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
      potential_objects = result_hash['Response']["Invoices"]
      objects_to_hydrate = potential_objects["Invoice"] if potential_objects
      self.process_objects(client, objects_to_hydrate)
    rescue Faraday::Error::ClientError => e
      if e.response[:body]
        return  ZohoInvoice::Error::ClientError.from_response(e.response)
      end
    end

    def self.find_by_multiple_customer_ids(client, ids, options={})
      new_hash = {}
      ids.each do |customer|
        new_hash[customer] = self.find_by_customer_id(client, customer, options)
      end
      return new_hash
    end

    def self.find_unpaid_by_customer_id(client, id, options = {})
      result_hash = client.get("/api/view/invoices/unpaid/customer/#{id}").body
      potential_objects = result_hash['Response']["Invoices"]
      objects_to_hydrate = potential_objects["Invoice"] if potential_objects
      self.process_objects(client, objects_to_hydrate)
    rescue Faraday::Error::ClientError => e
      if e.response[:body]
        return ZohoInvoice::Error::ClientError.from_response(e.response)
      end
    end

    def self.find_unpaid_by_multiple_customer_ids(client, ids, options={})
      new_hash = {}
      ids.each do |customer|
        new_hash[customer] = self.find_unpaid_by_customer_id(client, customer, options)
      end
      return new_hash
    end

  end
end
