class CreateMailDeliveryFailures < ActiveRecord::Migration[7.1]
  def change
    create_table :mail_delivery_failures do |t|
      t.string :email_address
      t.string :mailer_class
      t.string :mailer_action_method

      t.timestamps
    end
  end
end
