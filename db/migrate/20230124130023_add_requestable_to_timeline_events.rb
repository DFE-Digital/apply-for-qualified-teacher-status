# frozen_string_literal: true

class AddRequestableToTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :timeline_events, :requestable, polymorphic: true, index: true
  end
end
