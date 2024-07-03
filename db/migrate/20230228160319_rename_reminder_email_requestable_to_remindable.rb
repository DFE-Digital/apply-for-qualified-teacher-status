# frozen_string_literal: true

class RenameReminderEmailRequestableToRemindable < ActiveRecord::Migration[7.0]
  def change
    change_table :reminder_emails, bulk: true do |t|
      t.rename :requestable_id, :remindable_id
      t.rename :requestable_type, :remindable_type
    end
  end
end
