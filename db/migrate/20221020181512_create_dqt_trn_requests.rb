# frozen_string_literal: true

class CreateDQTTRNRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :dqt_trn_requests do |t|
      t.references :application_form, null: false, foreign_key: true
      t.uuid :request_id, null: false
      t.string :state, null: false, default: "pending"
      t.timestamps
    end
  end
end
