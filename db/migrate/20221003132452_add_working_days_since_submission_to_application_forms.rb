# frozen_string_literal: true

class AddWorkingDaysSinceSubmissionToApplicationForms < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :application_forms, :working_days_since_submission, :integer
  end
end
