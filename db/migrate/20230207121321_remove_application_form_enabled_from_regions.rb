# frozen_string_literal: true

class RemoveApplicationFormEnabledFromRegions < ActiveRecord::Migration[7.0]
  def change
    remove_column :regions, :application_form_enabled, :boolean, default: false
  end
end
