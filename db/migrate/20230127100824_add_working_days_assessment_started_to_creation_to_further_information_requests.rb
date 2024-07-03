# frozen_string_literal: true

class AddWorkingDaysAssessmentStartedToCreationToFurtherInformationRequests < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :further_information_requests,
               :working_days_assessment_started_to_creation,
               :integer
  end
end
