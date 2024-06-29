# frozen_string_literal: true

class AddStartedAtToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :started_at, :datetime
  end
end
