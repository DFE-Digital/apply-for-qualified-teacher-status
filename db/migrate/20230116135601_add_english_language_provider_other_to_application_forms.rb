class AddEnglishLanguageProviderOtherToApplicationForms < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :application_forms,
               :english_language_provider_other,
               :boolean,
               default: false,
               null: false
  end
end
