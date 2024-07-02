# frozen_string_literal: true

class AddChangeNamePermissionToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staff,
               :change_name_permission,
               :boolean,
               default: false,
               null: false
  end
end
