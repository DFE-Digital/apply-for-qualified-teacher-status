# frozen_string_literal: true

class AddSupportConsoleAccess < ActiveRecord::Migration[7.0]
  def change
    add_column :staff,
               :support_console_permission,
               :boolean,
               default: false,
               null: false
  end
end
