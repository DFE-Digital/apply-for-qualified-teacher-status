# frozen_string_literal: true

class AddRecommendationNoteToAssessment < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments,
               :recommendation_assessor_note,
               :text,
               null: false,
               default: ""
  end
end
