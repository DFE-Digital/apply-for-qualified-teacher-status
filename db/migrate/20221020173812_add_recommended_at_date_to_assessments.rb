# frozen_string_literal: true

class AddRecommendedAtDateToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :recommended_at, :date
  end
end
