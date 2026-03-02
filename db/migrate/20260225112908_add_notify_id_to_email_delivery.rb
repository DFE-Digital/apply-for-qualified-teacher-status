# frozen_string_literal: true

class AddNotifyIdToEmailDelivery < ActiveRecord::Migration[8.1]
  def change
    add_column :email_deliveries, :notify_id, :string
  end
end
