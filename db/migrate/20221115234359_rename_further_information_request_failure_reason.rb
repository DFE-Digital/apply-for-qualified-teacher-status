# frozen_string_literal: true

class RenameFurtherInformationRequestFailureReason < ActiveRecord::Migration[
  7.0
]
  def change
    rename_column :further_information_requests,
                  :failure_reason,
                  :failure_assessor_note
  end
end
