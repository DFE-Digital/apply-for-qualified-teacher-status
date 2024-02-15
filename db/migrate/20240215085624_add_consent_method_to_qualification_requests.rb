class AddConsentMethodToQualificationRequests < ActiveRecord::Migration[7.1]
  def change
    change_table :qualification_requests, bulk: true do |t|
      t.remove :signed_consent_document_required,
               type: :boolean,
               default: false,
               null: false
      t.string :consent_method, default: "unknown", null: false
    end
  end
end
