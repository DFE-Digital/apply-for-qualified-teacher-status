# frozen_string_literal: true

class CreateApplicationForms < ActiveRecord::Migration[7.0]
  def change
    create_table :application_forms do |t|
      t.string :reference, null: false, limit: 31
      t.string :status, null: false, default: "active"
      t.references :teacher, null: false, foreign_key: true
      t.references :eligibility_check, null: false, foreign_key: true
      t.timestamps
    end

    add_index :application_forms, :reference, unique: true
    add_index :application_forms, :status
  end
end
