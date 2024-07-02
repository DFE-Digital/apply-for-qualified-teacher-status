# frozen_string_literal: true

class RemoveTimelineEventAnnotation < ActiveRecord::Migration[7.0]
  def change
    remove_column :timeline_events,
                  :annotation,
                  :string,
                  default: "",
                  null: false
  end
end
