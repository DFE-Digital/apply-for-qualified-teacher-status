# frozen_string_literal: true

class AddAssigneeToTimelineEvent < ActiveRecord::Migration[7.0]
  def change
    add_reference :timeline_events, :assignee, foreign_key: { to_table: :staff }
  end
end
