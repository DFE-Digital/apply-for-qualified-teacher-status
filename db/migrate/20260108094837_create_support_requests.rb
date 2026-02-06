# frozen_string_literal: true

class CreateSupportRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :support_requests do |t|
      t.string :category_type
      t.string :application_enquiry_type

      t.string :name
      t.string :email
      t.string :application_reference
      t.text :comment

      t.datetime :submitted_at

      t.string :zendesk_ticket_id
      t.datetime :zendesk_ticket_created_at

      t.timestamps
    end
  end
end
