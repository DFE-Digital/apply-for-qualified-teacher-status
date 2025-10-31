# frozen_string_literal: true

class AddNationalInsuranceNumberToApplicationForm < ActiveRecord::Migration[8.0]
  def change
    add_column :application_forms, :national_insurance_number, :string
  end
end
