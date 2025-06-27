# frozen_string_literal: true

class CreatePrioritisationReferenceRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :prioritisation_reference_requests do |t|
      t.string :slug, null: false
      t.references :assessment, null: false, foreign_key: true
      t.references :work_history, null: false, foreign_key: true
      t.references :prioritisation_work_history_check,
                   null: false,
                   foreign_key: true

      t.boolean :contact_response
      t.text :contact_comment, default: "", null: false

      t.boolean :confirm_applicant_response
      t.text :confirm_applicant_comment, default: "", null: false

      t.datetime :received_at
      t.datetime :requested_at
      t.datetime :expired_at

      t.boolean :review_passed
      t.datetime :reviewed_at
      t.text :review_note, default: "", null: false

      t.timestamps
    end

    add_index :prioritisation_reference_requests, :slug, unique: true
  end
end
