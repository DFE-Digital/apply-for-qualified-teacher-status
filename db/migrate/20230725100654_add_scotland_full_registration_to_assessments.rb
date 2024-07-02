# frozen_string_literal: true

class AddScotlandFullRegistrationToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :scotland_full_registration, :boolean
  end
end
