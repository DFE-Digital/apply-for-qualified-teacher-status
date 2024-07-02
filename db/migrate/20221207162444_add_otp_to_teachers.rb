# frozen_string_literal: true

class AddOtpToTeachers < ActiveRecord::Migration[7.0]
  def change
    change_table :teachers, bulk: true do |t|
      t.string :secret_key
      t.integer :otp_guesses, default: 0, null: false
      t.datetime :otp_created_at
    end
  end
end
