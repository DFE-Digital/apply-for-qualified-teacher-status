# frozen_string_literal: true

class AddConsentDocumentToQualificationRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :qualification_requests,
               :unsigned_consent_document_downloaded,
               :boolean,
               default: false,
               null: false
  end
end
