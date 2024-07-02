# frozen_string_literal: true

class AddTeachingAuthorityProvidesWrittenStatementToRegions < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :regions,
               :teaching_authority_provides_written_statement,
               :boolean,
               default: false,
               null: false
  end
end
