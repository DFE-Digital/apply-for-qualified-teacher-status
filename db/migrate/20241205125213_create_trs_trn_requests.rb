# frozen_string_literal: true

class CreateTRSTRNRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :trs_trn_requests do |t|
      t.references :application_form, null: false, foreign_key: true
      t.uuid :request_id, null: false
      t.string :state, null: false, default: "pending"
      t.boolean :potential_duplicate

      t.timestamps
    end
  end
end
