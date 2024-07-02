# frozen_string_literal: true

class DropAssessmentSectionsSelectedFailureReasons < ActiveRecord::Migration[
  7.0
]
  def change
    remove_column :assessment_sections,
                  :selected_failure_reasons,
                  :jsonb,
                  default: {
                  },
                  null: false
  end
end
