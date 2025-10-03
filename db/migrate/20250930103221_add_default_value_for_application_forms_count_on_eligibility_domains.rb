# frozen_string_literal: true

class AddDefaultValueForApplicationFormsCountOnEligibilityDomains < ActiveRecord::Migration[
  8.0
]
  def change
    change_column_default :eligibility_domains,
                          :application_forms_count,
                          from: nil,
                          to: 0
  end
end
