# frozen_string_literal: true

class AddWaitingOnAndReceivedQualificationToApplicationForms < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :waiting_on_qualification, null: false, default: false
      t.boolean :received_qualification, null: false, default: false
    end
  end
end
