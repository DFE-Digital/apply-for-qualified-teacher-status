# frozen_string_literal: true

class AddNewReviewColumnsOnFurtherInformationRequestItem < ActiveRecord::Migration[
  8.0
]
  def change
    change_table :further_information_request_items, bulk: true do |t|
      t.column :review_decision_note, :text
      t.column :review_decision, :string
    end
  end
end
