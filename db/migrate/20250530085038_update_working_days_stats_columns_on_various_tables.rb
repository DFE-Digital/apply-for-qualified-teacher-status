# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class UpdateWorkingDaysStatsColumnsOnVariousTables < ActiveRecord::Migration[
  8.0
]
  def change
    # application_forms
    rename_column :application_forms,
                  :working_days_since_submission,
                  :working_days_between_submitted_and_today

    add_column :application_forms,
               :working_days_between_submitted_and_completed,
               :integer # Replacing working_days_submission_to_recommendation on assessments table

    # assessments
    rename_column :assessments,
                  :working_days_since_started,
                  :working_days_between_started_and_today
    rename_column :assessments,
                  :working_days_started_to_recommendation,
                  :working_days_between_started_and_completed
    rename_column :assessments,
                  :working_days_submission_to_started,
                  :working_days_between_submitted_and_started

    add_column :assessments,
               :working_days_between_started_and_verification_started,
               :integer # Newly tracked
    add_column :assessments,
               :working_days_between_submitted_and_verification_started,
               :integer # Newly tracked

    remove_column :assessments,
                  :working_days_submission_to_recommendation,
                  :integer # Replaced by working_days_between_submitted_and_completed on application_forms table

    # further_information_requests
    rename_column :further_information_requests,
                  :working_days_assessment_started_to_creation,
                  :working_days_between_assessment_started_to_requested

    remove_column :further_information_requests,
                  :working_days_since_received,
                  :integer # Not required or used
    remove_column :further_information_requests,
                  :working_days_received_to_recommendation,
                  :integer # Not required or used
  end
end
# rubocop:enable Rails/BulkChangeTable
