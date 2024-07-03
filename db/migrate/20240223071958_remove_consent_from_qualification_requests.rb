# frozen_string_literal: true

class RemoveConsentFromQualificationRequests < ActiveRecord::Migration[7.1]
  def change
    change_table :qualification_requests, bulk: true do |t|
      t.remove :consent_received_at, type: :datetime
      t.remove :consent_requested_at, type: :datetime
      t.remove :unsigned_consent_document_downloaded,
               type: :boolean,
               default: false,
               null: false
    end
  end
end
