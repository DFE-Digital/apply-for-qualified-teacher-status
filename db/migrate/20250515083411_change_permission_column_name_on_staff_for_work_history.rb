# frozen_string_literal: true

class ChangePermissionColumnNameOnStaffForWorkHistory < ActiveRecord::Migration[
  8.0
]
  def change
    rename_column :staff,
                  :change_work_history_permission,
                  :change_work_history_and_qualification_permission
  end
end
