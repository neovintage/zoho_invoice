require 'zoho_invoice/base'

module ZohoInvoice
  class Currency < Base

    READ_ATTRIBUTES = [
        :currency_id,
        :currency_code,
        :currency_name,
        :currency_symbol,
        :price_precision,
        :currency_format,
        :is_base_currency,
        :exchange_rate,
        :effective_date
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES - [:currency_id]

    define_object_attrs(*READ_ATTRIBUTES)

    def self.find_by_currency_id(currency, id, options = {})
      retrieve(currency, "/api/v3/settings/currencies/#{id}", false)
    end

    def self.all(currency)
      retrieve(currency, '/api/v3/settings/currencies')
    end

    def self.find(currency, id, options={})
      retrieve(currency, "/api/v3/settings/currencies/#{id}", false)
    end

  end
end
