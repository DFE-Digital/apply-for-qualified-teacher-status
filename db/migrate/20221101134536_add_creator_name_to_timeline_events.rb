# frozen_string_literal: true

class AddCreatorNameToTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :timeline_events,
               :creator_name,
               :string,
               null: false,
               default: ""
  end
end
