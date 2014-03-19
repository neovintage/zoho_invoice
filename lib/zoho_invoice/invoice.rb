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
      :status,                :notes,
      :customer_id,           :terms,
      :customer_name,         :custom_fields,
      :invoice_date,
      :payments_due,
      :due_date,
      :currency_code

    has_many :invoice_items

    def self.find_by_customer_id(client, id, options = {})
      retrieve(client, "/api/v3/invoices/customer/#{id}")
    end

    def self.find_by_multiple_customer_ids(client, ids, options={})
      new_hash = {}
      ids.each do |customer|
        new_hash[customer] = self.find_by_customer_id(client, customer, options)
      end
      return new_hash
    end

    def self.find_unpaid_by_customer_id(client, id, options = {})
      retrieve(client, "/api/v3/invoices/unpaid/customer/#{id}")
    end

    def self.find_unpaid_by_multiple_customer_ids(client, ids, options={})
      new_hash = {}
      ids.each do |customer|
        new_hash[customer] = self.find_unpaid_by_customer_id(client, customer, options)
      end
      return new_hash
    end

    def self.all(client)
      retrieve(client, '/api/v3/invoices')
    end

    def self.find(client, id, options={})
      retrieve(client, "/api/v3/invoices/#{id}")
    end

  end
end
