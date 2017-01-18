require 'zoho_invoice/base'

module ZohoInvoice
  class Tax < Base

    define_object_attrs :tax_id,
                        :tax_name,
                        :tax_percentage,
                        :tax_type,
                        :is_default_tax,
                        :is_editable

    def self.all(client, options = {})
      retrieve(client, '/api/v3/settings/taxes')
    end

    def self.all_groups(client, options = {})
      self.all(client, options).select { |t| t.tax_type == 'tax_group' }
    end

  end
end
