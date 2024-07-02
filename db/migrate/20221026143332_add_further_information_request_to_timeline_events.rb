# frozen_string_literal: true

class AddFurtherInformationRequestToTimelineEvents < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :timeline_events, bulk: true do |t|
      t.references :further_information_request, foreign_key: true
    end
  end
end
