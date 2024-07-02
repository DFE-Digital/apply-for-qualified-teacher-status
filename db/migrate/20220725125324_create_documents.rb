# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :type, null: false
      t.references :documentable, polymorphic: true
      t.timestamps
    end

    add_index :documents, :type
  end
end
