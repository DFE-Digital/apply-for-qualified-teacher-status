# frozen_string_literal: true

class AddApplicationFormEnabledToRegions < ActiveRecord::Migration[7.0]
  def change
    add_column :regions, :application_form_enabled, :boolean, default: false
  end
end
