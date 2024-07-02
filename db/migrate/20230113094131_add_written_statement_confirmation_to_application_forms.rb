# frozen_string_literal: true

class AddWrittenStatementConfirmationToApplicationForms < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :teaching_authority_provides_written_statement,
                default: false,
                null: false
      t.boolean :written_statement_confirmation, default: false, null: false
    end
  end
end
