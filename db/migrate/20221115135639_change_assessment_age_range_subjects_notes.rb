# frozen_string_literal: true

class ChangeAssessmentAgeRangeSubjectsNotes < ActiveRecord::Migration[7.0]
  def change
    remove_reference :assessments,
                     :age_range_note,
                     foreign_key: {
                       to_table: :notes,
                     }
    remove_reference :assessments,
                     :subjects_note,
                     foreign_key: {
                       to_table: :notes,
                     }

    change_table :assessments, bulk: true do |t|
      t.text :age_range_note, default: "", null: false
      t.text :subjects_note, default: "", null: false
    end
  end
end
