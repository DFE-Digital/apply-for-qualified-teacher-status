# frozen_string_literal: true

class AddAlternativeNamesToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.column :has_alternative_name, :bool
      t.column :alternative_given_names, :text, default: "", null: false
      t.column :alternative_family_name, :text, default: "", null: false
    end
  end
end
