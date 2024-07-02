# frozen_string_literal: true

class AddSubjectLimitedToApplicationForms < ActiveRecord::Migration[7.1]
  def change
    add_column :application_forms,
               :subject_limited,
               :boolean,
               null: false,
               default: false
  end
end
