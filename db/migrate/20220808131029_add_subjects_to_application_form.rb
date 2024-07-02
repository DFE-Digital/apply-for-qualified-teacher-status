# frozen_string_literal: true

class AddSubjectsToApplicationForm < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms,
               :subjects,
               :text,
               array: true,
               default: [],
               null: false
  end
end
