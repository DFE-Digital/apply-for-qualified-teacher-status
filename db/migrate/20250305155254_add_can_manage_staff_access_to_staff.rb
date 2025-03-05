# frozen_string_literal: true

class AddCanManageStaffAccessToStaff < ActiveRecord::Migration[7.2]
  def change
    add_column :staff, :can_manage_staff_access, :boolean, default: true, null: false
  end
end
