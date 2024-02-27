class AddConsentRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :consent_requests do |t|
      t.datetime :received_at
      t.datetime :requested_at
      t.datetime :expired_at
      t.boolean :unsigned_document_downloaded, default: false, null: false
      t.datetime :verified_at
      t.text :verify_note, default: "", null: false
      t.boolean :verify_passed
      t.references :assessment, null: false, foreign_key: true
      t.references :qualification, null: false, foreign_key: true
      t.timestamps
    end
  end
end
