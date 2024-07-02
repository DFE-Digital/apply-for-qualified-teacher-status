# frozen_string_literal: true

class RemoveRecognisedFromEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    remove_column :eligibility_checks, :recognised, :boolean
  end
end
