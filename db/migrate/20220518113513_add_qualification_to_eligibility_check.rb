# frozen_string_literal: true

class AddQualificationToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :qualification, :boolean
  end
end
