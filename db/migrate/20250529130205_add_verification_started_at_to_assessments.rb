# frozen_string_literal: true

class AddVerificationStartedAtToAssessments < ActiveRecord::Migration[8.0]
  def change
    add_column :assessments, :verification_started_at, :datetime
  end
end
