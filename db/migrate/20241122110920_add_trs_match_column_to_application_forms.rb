# frozen_string_literal: true

class AddTRSMatchColumnToApplicationForms < ActiveRecord::Migration[7.2]
  def up
    add_column :application_forms, :trs_match, :jsonb, default: {}

    ApplicationForm.update_all("trs_match = dqt_match")
  end

  def down
    remove_column :application_forms, :trs_match
  end
end
