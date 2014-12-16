module ZohoInvoice
  class Organization < Base

    define_object_attrs :organization_id,
      :name,
      :contact_name,
      :email,
      :is_default_org,
      :plan_type,
      :tax_group_enable,
      :plan_name,
      :plan_period,
      :language_code

  end
end
