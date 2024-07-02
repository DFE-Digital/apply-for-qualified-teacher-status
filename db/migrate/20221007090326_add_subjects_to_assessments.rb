# frozen_string_literal: true

class AddSubjectsToAssessments < ActiveRecord::Migration[7.0]
  def change
    change_table :assessments, bulk: true do |t|
      t.column :subjects, :text, array: true, default: [], null: false
      t.references :subjects_note, foreign_key: { to_table: :notes }
    end
  end
end
