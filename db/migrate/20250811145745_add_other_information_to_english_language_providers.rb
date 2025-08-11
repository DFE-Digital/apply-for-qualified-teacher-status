# frozen_string_literal: true

class AddOtherInformationToEnglishLanguageProviders < ActiveRecord::Migration[
  8.0
]
  def change
    add_column :english_language_providers,
               :other_information,
               :text,
               default: "",
               null: false
  end
end
