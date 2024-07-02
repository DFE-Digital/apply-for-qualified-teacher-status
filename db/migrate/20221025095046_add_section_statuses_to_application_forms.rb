# frozen_string_literal: true

class AddSectionStatusesToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.string :personal_information_status, default: "not_started", null: false
      t.string :identification_document_status,
               default: "not_started",
               null: false
      t.string :qualifications_status, default: "not_started", null: false
      t.string :age_range_status, default: "not_started", null: false
      t.string :subjects_status, default: "not_started", null: false
      t.string :work_history_status, default: "not_started", null: false
      t.string :registration_number_status, default: "not_started", null: false
      t.string :written_statement_status, default: "not_started", null: false
    end
  end
end
