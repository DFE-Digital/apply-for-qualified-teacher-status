# frozen_string_literal: true

class AddDegreeToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :degree, :boolean
  end
end
