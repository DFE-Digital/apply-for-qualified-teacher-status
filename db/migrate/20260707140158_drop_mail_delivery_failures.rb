# frozen_string_literal: true

class DropMailDeliveryFailures < ActiveRecord::Migration[8.1]
  def change
    drop_table :mail_delivery_failures do |t|
      t.string :email_address, null: false
      t.string :mailer_class, null: false
      t.string :mailer_action_method, null: false
      t.timestamps
      t.index :email_address
    end
  end
end
