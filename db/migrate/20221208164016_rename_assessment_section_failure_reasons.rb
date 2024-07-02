# frozen_string_literal: true

class RenameAssessmentSectionFailureReasons < ActiveRecord::Migration[7.0]
  def change
    rename_table :assessment_section_failure_reasons, :selected_failure_reasons
  end
end
