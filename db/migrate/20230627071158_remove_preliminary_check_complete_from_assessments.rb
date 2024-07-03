# frozen_string_literal: true

class RemovePreliminaryCheckCompleteFromAssessments < ActiveRecord::Migration[
  7.0
]
  def change
    remove_column :assessments, :preliminary_check_complete, :boolean
  end
end
