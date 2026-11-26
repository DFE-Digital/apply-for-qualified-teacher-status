# frozen_string_literal: true

class AddEventDataToTimelineEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :timeline_events, :event_data, :jsonb, default: {}, null: false
  end
end
