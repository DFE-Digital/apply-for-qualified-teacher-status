# frozen_string_literal: true

class AddPersonalInformationToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.column :given_names, :text, default: "", null: false
      t.column :family_name, :text, default: "", null: false
      t.column :date_of_birth, :date
    end
  end
end
