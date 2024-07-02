# frozen_string_literal: true

class AddNameToReminderEmails < ActiveRecord::Migration[7.1]
  def change
    add_column :reminder_emails,
               :name,
               :string,
               null: false,
               default: "expiration"
  end
end
