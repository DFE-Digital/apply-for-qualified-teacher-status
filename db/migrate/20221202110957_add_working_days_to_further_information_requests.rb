# frozen_string_literal: true

class AddWorkingDaysToFurtherInformationRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :further_information_requests,
               :working_days_received_to_recommendation,
               :integer
  end
end
