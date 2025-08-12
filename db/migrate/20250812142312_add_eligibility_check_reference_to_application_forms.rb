# frozen_string_literal: true

class AddEligibilityCheckReferenceToApplicationForms < ActiveRecord::Migration[
  8.0
]
  def change
    add_reference :application_forms, :eligibility_check, foreign_key: true
  end
end
