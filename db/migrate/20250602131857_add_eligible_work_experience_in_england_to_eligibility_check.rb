# frozen_string_literal: true

class AddEligibleWorkExperienceInEnglandToEligibilityCheck < ActiveRecord::Migration[
  8.0
]
  def change
    add_column :eligibility_checks,
               :eligible_work_experience_in_england,
               :boolean
  end
end
