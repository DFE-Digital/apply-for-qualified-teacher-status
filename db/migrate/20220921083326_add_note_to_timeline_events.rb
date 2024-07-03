# frozen_string_literal: true

class AddNoteToTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.references :note, foreign_key: true
    end
  end
end
