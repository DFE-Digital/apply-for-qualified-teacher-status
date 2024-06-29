# frozen_string_literal: true

class AddWaitingOnAndReceivedToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :waiting_on_professional_standing, null: false, default: false
      t.boolean :received_professional_standing, null: false, default: false

      t.boolean :waiting_on_further_information, null: false, default: false
      t.boolean :received_further_information, null: false, default: false

      t.boolean :waiting_on_reference, null: false, default: false
      t.boolean :received_reference, null: false, default: false
    end
  end
end
