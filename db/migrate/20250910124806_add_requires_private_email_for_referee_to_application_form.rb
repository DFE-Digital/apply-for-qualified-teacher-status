# frozen_string_literal: true

class AddRequiresPrivateEmailForRefereeToApplicationForm < ActiveRecord::Migration[
  8.0
]
  def change
    add_column :application_forms,
               :requires_private_email_for_referee,
               :boolean,
               null: false,
               default: false

    add_column :application_forms,
               :started_with_private_email_for_referee,
               :boolean,
               null: false,
               default: false
  end
end
