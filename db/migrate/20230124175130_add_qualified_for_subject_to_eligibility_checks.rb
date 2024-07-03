# frozen_string_literal: true

class AddQualifiedForSubjectToEligibilityChecks < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :qualified_for_subject, :boolean
  end
end
