# frozen_string_literal: true

class CreateAssessmentSections < ActiveRecord::Migration[7.0]
  def change
    create_table :assessment_sections do |t|
      t.references :assessment, null: false, foreign_key: true
      t.string :key, null: false
      t.boolean :passed
      t.string :checks, array: true, default: []
      t.string :failure_reasons, array: true, default: []
      t.string :selected_failure_reasons, array: true, default: []
      t.timestamps
    end

    add_index :assessment_sections, %i[assessment_id key], unique: true
  end
end
