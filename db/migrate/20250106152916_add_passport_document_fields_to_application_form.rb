# frozen_string_literal: true

class AddPassportDocumentFieldsToApplicationForm < ActiveRecord::Migration[7.2]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :requires_passport_as_identity_proof,
                null: false,
                default: false

      t.string :passport_document_status, null: false, default: "not_started"
      t.date :passport_expiry_date
    end
  end
end
