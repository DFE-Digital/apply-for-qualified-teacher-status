# frozen_string_literal: true

class CreateEligibilityChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :eligibility_checks do |t|
      t.boolean :free_of_sanctions

      t.timestamps
    end
  end
end
