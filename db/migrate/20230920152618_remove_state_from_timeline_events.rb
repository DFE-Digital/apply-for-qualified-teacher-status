# frozen_string_literal: true

class RemoveStateFromTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.remove :old_state, type: :string, default: "", null: false
      t.remove :new_state, type: :string, default: "", null: false
    end
  end
end
