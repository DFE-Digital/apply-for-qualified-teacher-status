class AddReviewToConsentRequests < ActiveRecord::Migration[7.1]
  def change
    change_table :consent_requests, bulk: true do |t|
      t.boolean :review_passed
      t.datetime :reviewed_at
      t.text :review_note, default: "", null: false
    end
  end
end
