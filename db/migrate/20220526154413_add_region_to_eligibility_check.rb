# frozen_string_literal: true

class AddRegionToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_reference :eligibility_checks, :region, index: false, foreign_key: true
  end
end
