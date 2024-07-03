# frozen_string_literal: true

class AddReviewedAtToRequestables < ActiveRecord::Migration[7.0]
  def change
    add_column :further_information_requests, :reviewed_at, :datetime

    change_table :professional_standing_requests, bulk: true do |t|
      t.datetime :reviewed_at
      t.boolean :passed
    end

    change_table :qualification_requests, bulk: true do |t|
      t.datetime :reviewed_at
      t.boolean :passed
    end
  end
end
