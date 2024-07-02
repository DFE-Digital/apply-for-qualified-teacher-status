# frozen_string_literal: true

class RenameStaffManageApplicationsPermissionToChangeWorkHistoryPermission < ActiveRecord::Migration[
  7.0
]
  def change
    rename_column :staff,
                  :manage_applications_permission,
                  :change_work_history_permission
  end
end
