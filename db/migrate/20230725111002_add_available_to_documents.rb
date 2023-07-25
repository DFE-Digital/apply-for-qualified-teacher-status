class AddAvailableToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :available, :boolean
  end
end
