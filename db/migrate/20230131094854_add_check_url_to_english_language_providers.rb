# frozen_string_literal: true

class AddCheckUrlToEnglishLanguageProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :english_language_providers, :check_url, :string
  end
end
