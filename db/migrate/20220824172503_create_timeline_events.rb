# frozen_string_literal: true

class CreateTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :timeline_events do |t|
      t.string :event_type, null: false
      t.references :application_form, null: false, foreign_key: true
      t.string :annotation, null: false, default: ""
      t.integer :creator_id, null: true
      t.string :creator_type, null: true
      t.timestamps
    end
  end
end
