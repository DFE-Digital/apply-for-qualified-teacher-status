# frozen_string_literal: true

class RenameApplicationFormStateToStatus < ActiveRecord::Migration[7.0]
  def change
    rename_column :application_forms, :state, :status
  end
end
