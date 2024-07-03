# frozen_string_literal: true

class AddAgeRangeToAssessments < ActiveRecord::Migration[7.0]
  def change
    change_table :assessments, bulk: true do |t|
      t.column :age_range_min, :integer
      t.column :age_range_max, :integer
      t.references :age_range_note, foreign_key: { to_table: :notes }
    end
  end
end
