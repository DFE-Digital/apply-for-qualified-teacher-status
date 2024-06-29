# frozen_string_literal: true

class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions do |t|
      t.references :country, null: false, foreign_key: true
      t.string :name, null: false, default: ""

      t.timestamps
    end

    add_index :regions, %i[country_id name], unique: true
  end
end
