# frozen_string_literal: true

class ChangeAssessmentReferencesVerified < ActiveRecord::Migration[7.0]
  def change
    change_column_null :assessments, :references_verified, true
    change_column_default :assessments,
                          :references_verified,
                          from: false,
                          to: nil
  end
end
