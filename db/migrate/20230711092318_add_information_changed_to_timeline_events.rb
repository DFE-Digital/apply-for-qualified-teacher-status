# frozen_string_literal: true

class AddInformationChangedToTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.references :work_history, foreign_key: true
      t.string :column_name, null: false, default: ""
      t.text :old_value, null: false, default: ""
      t.text :new_value, null: false, default: ""
    end
  end
end
