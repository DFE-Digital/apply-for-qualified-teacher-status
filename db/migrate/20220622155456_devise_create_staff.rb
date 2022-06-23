# frozen_string_literal: true

class DeviseCreateStaff < ActiveRecord::Migration[7.0]
  def change
    create_table :staff do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email

      t.integer :failed_attempts, default: 0, null: false
      t.string :unlock_token
      t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :staff, :email, unique: true
    add_index :staff, :reset_password_token, unique: true
    add_index :staff, :confirmation_token, unique: true
    add_index :staff, :unlock_token, unique: true
  end
end
