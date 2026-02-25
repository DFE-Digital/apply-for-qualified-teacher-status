# frozen_string_literal: true

class AddNotifyStatusToEmailDeliveries < ActiveRecord::Migration[8.1]
  def change
    change_table :email_deliveries, bulk: true do |t|
      t.column :notify_status, :string, default: "created"
      t.column :notify_completed_at, :datetime
    end
  end
end
