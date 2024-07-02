# frozen_string_literal: true

class AddCountryCodeToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :country_code, :string
  end
end
