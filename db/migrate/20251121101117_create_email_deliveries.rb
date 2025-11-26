# frozen_string_literal: true

class CreateEmailDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :email_deliveries do |t|
      t.references :application_form, foreign_key: true
      t.references :reference_request, foreign_key: true
      t.references :prioritisation_reference_request, foreign_key: true
      t.references :further_information_request, foreign_key: true

      t.string :mailer_class_name, default: "", null: false
      t.string :mailer_action_name, default: "", null: false
      t.string :to, default: "", null: false
      t.string :subject, default: "", null: false

      t.timestamps
    end
  end
end
