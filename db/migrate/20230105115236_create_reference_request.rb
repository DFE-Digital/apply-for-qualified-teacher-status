# frozen_string_literal: true

class CreateReferenceRequest < ActiveRecord::Migration[7.0]
  def change
    create_table :reference_requests do |t|
      t.string :slug, null: false
      t.references :assessment, null: false, foreign_key: true
      t.references :work_history, null: false, foreign_key: true
      t.string :state, null: false
      t.datetime :received_at
      t.boolean :dates_response
      t.boolean :hours_response
      t.boolean :children_response
      t.boolean :lessons_response
      t.boolean :reports_response
      t.text :additional_information_response, null: false, default: ""
      t.timestamps
    end

    add_index :reference_requests, :slug, unique: true
  end
end
