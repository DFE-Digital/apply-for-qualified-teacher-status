# frozen_string_literal: true

class RemoveOtpFromTeachers < ActiveRecord::Migration[7.0]
  def change
    change_table :teachers, bulk: true do |t|
      t.remove :secret_key, type: :string
      t.remove :otp_guesses, type: :integer, default: 0, null: false
      t.remove :otp_created_at, type: :datetime
    end
  end
end
