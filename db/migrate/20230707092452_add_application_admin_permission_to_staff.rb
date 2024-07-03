# frozen_string_literal: true

class AddApplicationAdminPermissionToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staff,
               :manage_applications_permission,
               :boolean,
               default: false,
               null: false
  end
end
