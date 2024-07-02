# frozen_string_literal: true

class AddNewFieldsToEnglishLanguageProviders < ActiveRecord::Migration[7.0]
  def change
    change_table :english_language_providers, bulk: true do |t|
      t.string :url, null: false, default: ""
      t.string :b2_level_requirement_prefix, null: false, default: ""
    end
  end
end
