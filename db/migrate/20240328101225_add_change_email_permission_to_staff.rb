# frozen_string_literal: true

class AddChangeEmailPermissionToStaff < ActiveRecord::Migration[7.1]
  def change
    add_column :staff,
               :change_email_permission,
               :boolean,
               default: false,
               null: false
  end
end
