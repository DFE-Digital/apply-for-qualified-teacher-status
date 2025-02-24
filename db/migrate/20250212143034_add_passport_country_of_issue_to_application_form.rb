# frozen_string_literal: true

class AddPassportCountryOfIssueToApplicationForm < ActiveRecord::Migration[7.2]
  def change
    add_column :application_forms, :passport_country_of_issue_code, :string
  end
end
