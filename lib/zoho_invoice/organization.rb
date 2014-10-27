require 'zoho_invoice/base'

module ZohoInvoice
  class Organization < Base

    READ_ATTRIBUTES = [
        :organization_id,
        :name,
        :contact_name,
        :email,
        :is_default_org,
        :plan_type,
        :tax_group_enabled,
        :zi_migration_status,
        :plan_name,
        :plan_period,
        :language_code,
        :fiscal_year_start_month,
        :account_created_date,
        :account_created_date_formatted,
        :time_zone,
        :is_org_active,
        :currency_id,
        :currency_code,
        :currency_symbol,
        :currency_format,
        :price_precision
    ]

    CREATE_UPDATE_ATTRIBUTES = READ_ATTRIBUTES - [:organization_id]

    define_object_attrs(*READ_ATTRIBUTES)

    def self.create(client, options = {})
      raise ZohoInvoice::ActionNotSupportedError
    end

    def save
      raise ZohoInvoice::ActionNotSupportedError
    end

    def self.all(client)
      retrieve(client, '/api/v3/organizations')
    end

    def self.find(client, id, options={})
      retrieve(client, "/api/v3/organizations/#{id}", false)
    end

  end
end