# frozen_string_literal: true

class AddCompletedToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :completed, :boolean, default: false
  end
end
