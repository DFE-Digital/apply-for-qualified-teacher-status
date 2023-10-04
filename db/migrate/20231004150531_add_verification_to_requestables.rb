class AddVerificationToRequestables < ActiveRecord::Migration[7.0]
  def change
    change_table :further_information_requests, bulk: true do |t|
      t.rename :passed, :review_passed
      t.rename :failure_assessor_note, :review_note
    end

    change_table :professional_standing_requests, bulk: true do |t|
      t.rename :passed, :review_passed
      t.rename :failure_assessor_note, :review_note

      t.boolean :verify_passed
      t.text :verify_note, default: "", null: false
      t.datetime :verified_at
    end

    change_table :qualification_requests, bulk: true do |t|
      t.rename :passed, :review_passed
      t.rename :failure_assessor_note, :review_note

      t.boolean :verify_passed
      t.text :verify_note, default: "", null: false
      t.datetime :verified_at
    end

    change_table :reference_requests, bulk: true do |t|
      t.rename :passed, :review_passed
      t.rename :failure_assessor_note, :review_note

      t.boolean :verify_passed
      t.text :verify_note, default: "", null: false
      t.datetime :verified_at
    end
  end
end
