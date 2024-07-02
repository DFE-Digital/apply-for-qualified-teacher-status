# frozen_string_literal: true

class AddAgeRangeToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.column :age_range_min, :integer
      t.column :age_range_max, :integer
    end
  end
end
