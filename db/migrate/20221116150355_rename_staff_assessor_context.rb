# frozen_string_literal: true

class RenameStaffAssessorContext < ActiveRecord::Migration[7.0]
  def change
    rename_column :staff, :assessor, :award_decline_permission
  end
end
