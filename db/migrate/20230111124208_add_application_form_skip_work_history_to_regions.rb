# frozen_string_literal: true

class AddApplicationFormSkipWorkHistoryToRegions < ActiveRecord::Migration[7.0]
  def change
    add_column :regions,
               :application_form_skip_work_history,
               :boolean,
               default: false,
               null: false
  end
end
