# frozen_string_literal: true

class AddSubjectLimitedToCountries < ActiveRecord::Migration[7.0]
  def change
    add_column :countries,
               :subject_limited,
               :boolean,
               default: false,
               null: false
  end
end
