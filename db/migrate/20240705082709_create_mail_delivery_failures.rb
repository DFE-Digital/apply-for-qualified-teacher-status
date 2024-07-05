# frozen_string_literal: true

class CreateMailDeliveryFailures < ActiveRecord::Migration[7.1]
  def change
    create_table :mail_delivery_failures do |t|
      t.string :email_address, null: false
      t.string :mailer_class, null: false
      t.string :mailer_action_method, null: false

      t.timestamps
    end

    add_index :mail_delivery_failures, :email_address
  end
end
