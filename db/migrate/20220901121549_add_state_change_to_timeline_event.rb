# frozen_string_literal: true

class AddStateChangeToTimelineEvent < ActiveRecord::Migration[7.0]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.string :old_state, null: false, default: ""
      t.string :new_state, null: false, default: ""
    end
  end
end
