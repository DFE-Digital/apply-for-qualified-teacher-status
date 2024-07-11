# frozen_string_literal: true

class AddSuitabilityRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :suitability_records do |t|
      t.text :country_code, limit: 7, null: false, default: ""
      t.date :date_of_birth

      t.text :note, null: false

      t.datetime :archived_at
      t.text :archive_note, null: false, default: ""

      t.timestamps
    end

    create_table :suitability_record_emails do |t|
      t.text :value, null: false
      t.text :canonical, null: false
      t.references :suitability_record, null: false, foreign_key: true
      t.timestamps
    end

    create_table :suitability_record_names do |t|
      t.text :value, null: false
      t.references :suitability_record, null: false, foreign_key: true
      t.timestamps
    end

    create_join_table :suitability_records, :application_forms
  end
end
