# frozen_string_literal: true

class ChangeAssessmentSectionSelectedFailureReasons < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :assessment_sections, bulk: true do |t|
      t.remove :selected_failure_reasons,
               type: :string,
               array: true,
               default: []
      t.jsonb :selected_failure_reasons, default: {}, null: false
    end
  end
end
