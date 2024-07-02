# frozen_string_literal: true

class ChangeAssessmentRecommendedAt < ActiveRecord::Migration[7.0]
  def up
    change_column :assessments, :recommended_at, :datetime
  end

  def down
    change_column :assessments, :recommended_at, :date
  end
end
