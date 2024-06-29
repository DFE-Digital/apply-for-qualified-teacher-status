# frozen_string_literal: true

class AddInductionRequiredToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :induction_required, :boolean
  end
end
