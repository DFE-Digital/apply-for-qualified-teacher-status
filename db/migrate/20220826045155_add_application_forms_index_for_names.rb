# frozen_string_literal: true

class AddApplicationFormsIndexForNames < ActiveRecord::Migration[7.0]
  def change
    add_index :application_forms, :given_names
    add_index :application_forms, :family_name
  end
end
