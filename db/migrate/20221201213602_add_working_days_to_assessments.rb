# frozen_string_literal: true

class AddWorkingDaysToAssessments < ActiveRecord::Migration[7.0]
  def change
    change_table :assessments, bulk: true do |t|
      t.integer :working_days_started_to_recommendation
      t.integer :working_days_submission_to_recommendation
      t.integer :working_days_submission_to_started
    end
  end
end
