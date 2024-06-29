# frozen_string_literal: true

class ChangeReminderEmailsToPolymorphicAssociation < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :reminder_emails, bulk: true do |t|
      t.remove_foreign_key :further_information_requests
      t.remove_index [:further_information_request_id]
      t.rename :further_information_request_id, :requestable_id
      t.string :requestable_type,
               null: false,
               default: "FurtherInformationRequest"
      t.index %i[requestable_type requestable_id]
    end

    change_column_default :reminder_emails,
                          :requestable_type,
                          from: "FurtherInformationRequest",
                          to: ""
  end
end
