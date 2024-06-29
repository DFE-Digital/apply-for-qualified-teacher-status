# frozen_string_literal: true

class AddWorkExperienceToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :work_experience, :string
  end
end
