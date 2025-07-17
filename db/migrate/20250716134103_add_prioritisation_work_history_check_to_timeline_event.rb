# frozen_string_literal: true

class AddPrioritisationWorkHistoryCheckToTimelineEvent < ActiveRecord::Migration[
  8.0
]
  def change
    add_reference :timeline_events,
                  :prioritisation_work_history_check,
                  foreign_key: true
  end
end
