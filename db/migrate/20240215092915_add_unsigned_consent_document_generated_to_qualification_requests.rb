# frozen_string_literal: true

class AddUnsignedConsentDocumentGeneratedToQualificationRequests < ActiveRecord::Migration[
  7.1
]
  def change
    add_column :qualification_requests,
               :unsigned_consent_document_generated,
               :boolean,
               default: false,
               null: false
  end
end
