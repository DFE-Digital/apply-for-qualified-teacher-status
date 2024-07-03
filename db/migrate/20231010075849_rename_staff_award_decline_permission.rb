# frozen_string_literal: true

class RenameStaffAwardDeclinePermission < ActiveRecord::Migration[7.1]
  def change
    rename_column :staff, :award_decline_permission, :assess_permission
  end
end
