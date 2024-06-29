# frozen_string_literal: true

class AddUnsignedConsentDocumentGeneratedToAssessment < ActiveRecord::Migration[
  7.1
]
  def change
    add_column :assessments,
               :unsigned_consent_document_generated,
               :boolean,
               default: false,
               null: false

    remove_column :qualification_requests,
                  :unsigned_consent_document_generated,
                  :boolean,
                  default: false,
                  null: false
  end
end
