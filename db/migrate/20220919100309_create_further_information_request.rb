# frozen_string_literal: true

class CreateFurtherInformationRequest < ActiveRecord::Migration[7.0]
  def change
    create_table :further_information_requests do |t|
      t.references :assessment
      t.string :state, null: false
      t.datetime :received_at
      t.timestamps
    end
  end
end
