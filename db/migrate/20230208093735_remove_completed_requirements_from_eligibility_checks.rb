# frozen_string_literal: true

class RemoveCompletedRequirementsFromEligibilityChecks < ActiveRecord::Migration[
  7.0
]
  def change
    remove_column :eligibility_checks, :completed_requirements, :boolean
  end
end
