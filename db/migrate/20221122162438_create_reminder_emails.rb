# frozen_string_literal: true

class CreateReminderEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :reminder_emails do |t|
      t.references :further_information_request, null: false, foreign_key: true
      t.timestamps
    end
  end
end
