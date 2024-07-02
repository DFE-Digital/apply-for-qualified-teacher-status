# frozen_string_literal: true

class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :code, null: false
      t.boolean :legacy, null: false, default: false

      t.timestamps
    end

    add_index :countries, :code, unique: true
  end
end
