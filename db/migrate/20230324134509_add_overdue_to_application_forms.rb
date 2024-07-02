# frozen_string_literal: true

class AddOverdueToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :overdue_further_information, null: false, default: false
      t.boolean :overdue_professional_standing, null: false, default: false
      t.boolean :overdue_qualification, null: false, default: false
      t.boolean :overdue_reference, null: false, default: false
    end
  end
end
