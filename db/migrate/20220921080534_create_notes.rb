# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.references :application_form, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :staff }
      t.text :text, null: false
      t.timestamps
    end
  end
end
