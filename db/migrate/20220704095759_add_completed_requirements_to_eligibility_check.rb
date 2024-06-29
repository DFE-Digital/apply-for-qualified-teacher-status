# frozen_string_literal: true

class AddCompletedRequirementsToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :completed_requirements, :boolean
  end
end
