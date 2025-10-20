# frozen_string_literal: true

class AddApplicationHoldToTimelineEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :timeline_events, :application_hold, foreign_key: true
  end
end
