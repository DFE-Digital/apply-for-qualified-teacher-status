# frozen_string_literal: true

class RemoveEligibilityCheckFromApplicationForm < ActiveRecord::Migration[7.0]
  def change
    remove_reference :application_forms,
                     :eligibility_check,
                     null: false,
                     foreign_key: true
  end
end
