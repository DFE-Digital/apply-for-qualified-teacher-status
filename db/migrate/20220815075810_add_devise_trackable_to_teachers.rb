# frozen_string_literal: true

class AddDeviseTrackableToTeachers < ActiveRecord::Migration[7.0]
  def change
    change_table :teachers, bulk: true do |t|
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
    end
  end
end
