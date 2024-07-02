# frozen_string_literal: true

class AddPassedToReferenceRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :reference_requests, bulk: true do |t|
      t.boolean :passed
      t.datetime :reviewed_at
    end
  end
end
