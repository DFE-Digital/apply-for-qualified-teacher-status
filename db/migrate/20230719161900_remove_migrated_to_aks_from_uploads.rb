# frozen_string_literal: true

class RemoveMigratedToAksFromUploads < ActiveRecord::Migration[7.0]
  def change
    remove_column :uploads,
                  :migrated_to_aks,
                  :boolean,
                  null: false,
                  default: false
  end
end
