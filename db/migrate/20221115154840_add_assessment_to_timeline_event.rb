# frozen_string_literal: true

class AddAssessmentToTimelineEvent < ActiveRecord::Migration[7.0]
  def change
    add_reference :timeline_events, :assessment, foreign_key: true
  end
end
