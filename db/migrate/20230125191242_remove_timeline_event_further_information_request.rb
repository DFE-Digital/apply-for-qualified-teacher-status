# frozen_string_literal: true

class RemoveTimelineEventFurtherInformationRequest < ActiveRecord::Migration[
  7.0
]
  def change
    remove_reference :timeline_events,
                     :further_information_request,
                     foreign_key: true
  end
end
