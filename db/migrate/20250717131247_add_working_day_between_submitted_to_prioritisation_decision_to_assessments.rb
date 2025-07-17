# frozen_string_literal: true

class AddWorkingDayBetweenSubmittedToPrioritisationDecisionToAssessments < ActiveRecord::Migration[
  8.0
]
  def change
    add_column :assessments,
               :working_days_between_submitted_and_prioritisation_decision,
               :integer
  end
end
