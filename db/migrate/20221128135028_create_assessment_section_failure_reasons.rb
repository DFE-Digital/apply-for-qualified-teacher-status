# frozen_string_literal: true

class CreateAssessmentSectionFailureReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :assessment_section_failure_reasons do |t|
      t.references :assessment_section,
                   null: false,
                   foreign_key: true,
                   index: {
                     name: "index_as_failure_reason_assessment_section_id",
                   }
      t.string :key, null: false
      t.text :assessor_feedback
      t.timestamps
    end
  end
end
