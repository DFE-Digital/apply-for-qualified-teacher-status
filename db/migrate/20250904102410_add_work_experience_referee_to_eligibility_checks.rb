# frozen_string_literal: true

class AddWorkExperienceRefereeToEligibilityChecks < ActiveRecord::Migration[8.0]
  def change
    add_column :eligibility_checks, :work_experience_referee, :boolean
  end
end
