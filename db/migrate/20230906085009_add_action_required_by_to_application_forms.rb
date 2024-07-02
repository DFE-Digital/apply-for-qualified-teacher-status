# frozen_string_literal: true

class AddActionRequiredByToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms,
               :action_required_by,
               :string,
               default: "none",
               null: false
    add_index :application_forms, :action_required_by
  end
end
