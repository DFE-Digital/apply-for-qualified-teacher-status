# frozen_string_literal: true

class AddPrioritisationTimestampsOnAssessments < ActiveRecord::Migration[8.0]
  def change
    change_table :assessments, bulk: true do |t|
      t.datetime :prioritisation_decision_at
      t.boolean :prioritised
    end
  end
end
