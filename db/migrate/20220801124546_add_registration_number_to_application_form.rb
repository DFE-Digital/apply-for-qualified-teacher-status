# frozen_string_literal: true

class AddRegistrationNumberToApplicationForm < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :registration_number, :text
  end
end
