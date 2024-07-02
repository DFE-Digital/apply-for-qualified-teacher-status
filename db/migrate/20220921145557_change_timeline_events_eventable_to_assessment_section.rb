# frozen_string_literal: true

class ChangeTimelineEventsEventableToAssessmentSection < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.rename :eventable_id, :assessment_section_id
      t.remove :eventable_type, type: :string
      t.foreign_key :assessment_sections
      t.index :assessment_section_id
    end
  end
end
