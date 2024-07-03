# frozen_string_literal: true

class RemoveConfirmationFromUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :teachers, bulk: true do |t|
      t.remove :confirmation_sent_at, type: :datetime
      t.remove :confirmation_token, type: :string
      t.remove :confirmed_at, type: :datetime
      t.remove :unconfirmed_email, type: :string
    end
  end
end
