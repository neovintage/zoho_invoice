require 'zoho_invoice/invoice_item'

module ZohoInvoice
  class Invoice < Base

    READ_ATTRIBUTES = [
      :invoice_id,
      :created_time,
      :exchange_rate,
      :last_modified_time,
      :l_f_name,
      :last_sync_time,
      :late_fee_amount,
      :source,
      :total,
      :reference_id,
      :invoice_item_total,
      :invoice_number,
      :tax_total,
      :p_o_number,
      :balance,
      :status,
      :notes,
      :customer_id,
      :terms,
      :customer_name,
      :custom_fields,
      :invoice_date,
      :payments_due,
      :due_date,
      :currency_code,
      :additional_field1,
      :adjustment,
      :adjustment_description,
      :allow_partial_payments,
      :contact_persons,
      :date,
      :description,
      :discount,
      :discount_type,
      :expense_id,
      :gateway_name,
      :invoiced_estimate_id,
      :is_discount_before_tax,
      :item_id,
      :line_items,
      :name,
      :payment_gateways,
      :payment_options,
      :payment_terms,
      :payment_terms_label,
      :project_id,
      :quantity,
      :rate,
      :recurring_invoice_id,
      :salesperson_name,
      :shipping_charge,
      :tax_id,
      :template_id,
      :time_entry_ids,
      :unit
    ]

    CREATE_ATTRIBUTES = READ_ATTRIBUTES

    UPDATE_ATTRIBUTES_SAVE = CREATE_ATTRIBUTES - [
      :invoice_id,
      :created_time,
      :exchange_rate,
      :last_modified_time,
      :l_f_name,
      :last_sync_time,
      :late_fee_amount,
      :source,
      :total,
      :reference_id,
      :invoice_item_total,
      :invoice_number,
      :tax_total,
      :p_o_number,
      :balance,
      :status,
      #:notes,
      #:customer_id,
      #:terms,
      :customer_name,
      #:custom_fields,
      :invoice_date,
      :payments_due,
      :due_date,
      :currency_code,
      #:additional_field1,
      :adjustment,
      :adjustment_description,
      :allow_partial_payments,
      :contact_persons,
      :date,
      #:description,
      :discount,
      :discount_type,
      :expense_id,
      :gateway_name,
      :invoiced_estimate_id,
      :is_discount_before_tax,
      :item_id,
      :line_items,
      #:name,
      :payment_gateways,
      :payment_options,
      :payment_terms,
      :payment_terms_label,
      :project_id,
      :quantity,
      :rate,
      :recurring_invoice_id,
      :salesperson_name,
      :shipping_charge,
      :tax_id,
      :template_id,
      :time_entry_ids,
      :unit
    ]
    UPDATE_ATTRIBUTES = CREATE_ATTRIBUTES - [
      :invoice_id,
      #:created_time,
      :exchange_rate,
      #:last_modified_time,
      #:l_f_name,
      #:last_sync_time,
      #:late_fee_amount,
      #:source,
      #:total,
      #:reference_id,
      #:invoice_item_total,
      :invoice_number,
      #:tax_total,
      #:p_o_number,
      #:balance,
      #:status,
      #:notes,
      #:customer_id,
      #:terms,
      :customer_name,
      #:custom_fields,
      #
      #:invoice_date,
      #:payments_due,
      :due_date,
      #:currency_code,
      #
      #:additional_field1,
      #
      :adjustment,
      :adjustment_description,
      #:allow_partial_payments,
      #:contact_persons,
      :date,
      #
      #:description,
      :discount,
      :discount_type,
      :expense_id,
      :gateway_name,
      :invoiced_estimate_id,
      :is_discount_before_tax,
      :item_id,
      :line_items,
      #:name,
      :payment_gateways,
      :payment_options,
      :payment_terms,
      :payment_terms_label,
      :project_id,
      :quantity,
      :rate,
      :recurring_invoice_id,
      :salesperson_name,
      :shipping_charge,
      :tax_id,
      :template_id,
      :time_entry_ids,
      :unit
    ]

    define_object_attrs(*READ_ATTRIBUTES)

    has_many :invoice_items

    def self.find_by_customer_id(client, id, options = {})
      retrieve(client, "/api/v3/invoices/customer/#{id}", false)
    end

    def self.find_by_multiple_customer_ids(client, ids, options={})
      new_hash = {}
      ids.each do |customer|
        new_hash[customer] = self.find_by_customer_id(client, customer, options)
      end
      return new_hash
    end

    def self.find_unpaid_by_customer_id(client, id, options = {})
      retrieve(client, "/api/v3/invoices/unpaid/customer/#{id}", false)
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
      retrieve(client, "/api/v3/invoices/#{id}", false)
    end

  end
end
