# frozen_string_literal: true

class AddMessageSubjectToTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :timeline_events,
               :message_subject,
               :string,
               null: false,
               default: ""
  end
end
