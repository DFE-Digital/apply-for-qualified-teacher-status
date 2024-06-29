# frozen_string_literal: true

class AddEnglishLanguageToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.string :english_language_status, default: "not_started", null: false
      t.boolean :english_language_citizenship_exempt
      t.boolean :english_language_qualification_exempt
      t.string :english_language_proof_method
      t.references :english_language_provider, foreign_key: true
      t.text :english_language_provider_reference, default: "", null: false
    end
  end
end
