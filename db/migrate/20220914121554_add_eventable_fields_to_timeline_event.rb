# frozen_string_literal: true

class AddEventableFieldsToTimelineEvent < ActiveRecord::Migration[7.0]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.references :eventable, polymorphic: true
    end
  end
end
