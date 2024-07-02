# frozen_string_literal: true

class AddRequiresPreliminaryCheckToApplicationForms < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :application_forms,
               :requires_preliminary_check,
               :boolean,
               default: false,
               null: false
  end
end
