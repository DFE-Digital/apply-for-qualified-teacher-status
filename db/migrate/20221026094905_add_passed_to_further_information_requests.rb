# frozen_string_literal: true

class AddPassedToFurtherInformationRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :further_information_requests, bulk: true do |t|
      t.boolean :passed
      t.string :failure_reason, null: false, default: ""
    end
  end
end
