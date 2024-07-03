# frozen_string_literal: true

class AddMigratedToAksToUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :uploads, :migrated_to_aks, :boolean, null: false, default: false
  end
end
