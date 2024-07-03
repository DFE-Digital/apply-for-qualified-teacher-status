# frozen_string_literal: true

class AddResultToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :completed_at, :datetime
  end
end
