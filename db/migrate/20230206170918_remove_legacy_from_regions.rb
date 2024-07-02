# frozen_string_literal: true

class RemoveLegacyFromRegions < ActiveRecord::Migration[7.0]
  def change
    remove_column :regions, :legacy, :boolean, null: false, default: true
  end
end
