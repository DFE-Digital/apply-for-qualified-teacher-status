# frozen_string_literal: true

class AddPrioritisedIndexToAssessment < ActiveRecord::Migration[8.0]
  def change
    add_index :assessments, :prioritised
  end
end
