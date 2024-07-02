# frozen_string_literal: true

class AddReferencesVerifiedToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments,
               :references_verified,
               :boolean,
               default: false,
               null: false
  end
end
