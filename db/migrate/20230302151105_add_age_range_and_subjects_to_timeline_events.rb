# frozen_string_literal: true

class AddAgeRangeAndSubjectsToTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.integer :age_range_min
      t.integer :age_range_max
      t.text :age_range_note, default: "", null: false
      t.text :subjects, array: true, default: [], null: false
      t.text :subjects_note, default: "", null: false
    end
  end
end
