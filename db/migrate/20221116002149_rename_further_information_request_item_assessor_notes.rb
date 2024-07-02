# frozen_string_literal: true

class RenameFurtherInformationRequestItemAssessorNotes < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :further_information_request_items, bulk: true do |t|
      t.rename :failure_reason, :failure_reason_key
      t.rename :assessor_notes, :failure_reason_assessor_feedback
    end
  end
end
