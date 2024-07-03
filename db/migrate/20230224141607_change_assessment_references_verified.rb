# frozen_string_literal: true

class ChangeAssessmentReferencesVerified < ActiveRecord::Migration[7.0]
  def change
    change_table :assessments, bulk: true do |t|
      t.change_null :references_verified, true
      t.change_default :references_verified, from: false, to: nil
    end
  end
end
