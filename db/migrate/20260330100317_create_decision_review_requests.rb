# frozen_string_literal: true

class CreateDecisionReviewRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :decision_review_requests do |t|
      t.references :assessment, null: false, foreign_key: true

      t.text :comment, default: "", null: false
      t.boolean :has_supporting_documents

      t.datetime :received_at

      t.boolean :review_passed
      t.datetime :reviewed_at
      t.text :review_note, default: "", null: false

      t.timestamps
    end
  end
end
