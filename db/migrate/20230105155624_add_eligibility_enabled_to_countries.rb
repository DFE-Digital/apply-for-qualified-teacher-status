# frozen_string_literal: true

class AddEligibilityEnabledToCountries < ActiveRecord::Migration[7.0]
  def change
    add_column :countries,
               :eligibility_enabled,
               :boolean,
               default: true,
               null: false
  end
end
