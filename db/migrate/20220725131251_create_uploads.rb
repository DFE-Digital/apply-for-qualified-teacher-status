# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :uploads do |t|
      t.references :document, null: false, foreign_key: true
      t.boolean :translation, null: false
      t.timestamps
    end
  end
end
