# frozen_string_literal: true

class CreateQualificationRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :qualification_requests do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :qualification, null: false, foreign_key: true
      t.string :state, null: false
      t.datetime :received_at
      t.text :location_note, null: false, default: ""
      t.timestamps
    end
  end
end
