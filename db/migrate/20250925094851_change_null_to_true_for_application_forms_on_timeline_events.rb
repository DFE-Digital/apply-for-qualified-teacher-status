# frozen_string_literal: true

class ChangeNullToTrueForApplicationFormsOnTimelineEvents < ActiveRecord::Migration[
  8.0
]
  def change
    change_column_null :timeline_events, :application_form_id, true
  end
end
