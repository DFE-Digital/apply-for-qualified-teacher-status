class AddPassportDocumentFieldsToApplicationForm < ActiveRecord::Migration[7.2]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :old_identification_document_upload, null: false, default: true
      t.string :passport_document_status, null: false, default: "not_started"
    end
  end
end
