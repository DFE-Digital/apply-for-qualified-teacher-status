# frozen_string_literal: true

class AddRequiresPrivateEmailForRefereeToApplicationForm < ActiveRecord::Migration[
  8.0
]
  def change
    change_table :application_forms, bulk: true do |t|
      t.column :requires_private_email_for_referee,
               :boolean,
               default: false,
               null: false
      t.column :started_with_private_email_for_referee,
               :boolean,
               default: false,
               null: false
    end
  end
end
