# frozen_string_literal: true

class AddWorkingDaysToAssessmentsAndFurtherInformationRequests < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :assessments, :working_days_since_started, :integer
    add_column :further_information_requests,
               :working_days_since_received,
               :integer
  end
end
