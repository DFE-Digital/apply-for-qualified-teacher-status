# frozen_string_literal: true

class AddAcceptedTestsToEnglishLanguageProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :english_language_providers,
               :accepted_tests,
               :string,
               default: "",
               null: false
  end
end
