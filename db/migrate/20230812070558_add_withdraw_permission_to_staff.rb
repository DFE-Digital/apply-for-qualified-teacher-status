# frozen_string_literal: true

class AddWithdrawPermissionToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staff,
               :withdraw_permission,
               :boolean,
               default: false,
               null: false
  end
end
