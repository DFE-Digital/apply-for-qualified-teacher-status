# frozen_string_literal: true

class AddWrittenStatementOptional < ActiveRecord::Migration[7.0]
  def change
    add_column :regions,
               :written_statement_optional,
               :boolean,
               default: false,
               null: false

    add_column :application_forms,
               :written_statement_optional,
               :boolean,
               default: false,
               null: false
  end
end
