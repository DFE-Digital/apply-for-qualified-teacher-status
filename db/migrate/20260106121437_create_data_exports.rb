# frozen_string_literal: true

class CreateDataExports < ActiveRecord::Migration[8.0]
  def change
    create_table :export_audits do |t|
      t.string :export_type, null: false
      t.references :exported_by, null: false, foreign_key: { to_table: :staff }
      t.jsonb :filter_params, default: {}

      t.timestamps
    end
  end
end
