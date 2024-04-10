class RemoveCompletedFromDocuments < ActiveRecord::Migration[7.1]
  def change
    remove_column :documents, :completed, :boolean, default: false
  end
end
