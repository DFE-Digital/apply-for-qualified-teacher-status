# frozen_string_literal: true

class AddManageStaffPermissionToStaff < ActiveRecord::Migration[7.2]
  def change
    add_column :staff,
               :manage_staff_permission,
               :boolean,
               null: false,
               default: false
  end
end
