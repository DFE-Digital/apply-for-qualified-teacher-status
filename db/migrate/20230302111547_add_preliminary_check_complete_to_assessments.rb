# frozen_string_literal: true

class AddPreliminaryCheckCompleteToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :preliminary_check_complete, :boolean
  end
end
