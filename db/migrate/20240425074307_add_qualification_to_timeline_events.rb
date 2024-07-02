# frozen_string_literal: true

class AddQualificationToTimelineEvents < ActiveRecord::Migration[7.1]
  def change
    add_reference :timeline_events, :qualification, foreign_key: true
  end
end
