# frozen_string_literal: true

class AddConsentToQualificationRequests < ActiveRecord::Migration[7.1]
  def change
    change_table :qualification_requests, bulk: true do |t|
      t.datetime :consent_received_at
      t.datetime :consent_requested_at
      t.boolean :signed_consent_document_required, default: false, null: false
    end
  end
end
