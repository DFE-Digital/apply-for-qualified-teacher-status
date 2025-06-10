# frozen_string_literal: true

class AddIncludesPrioritisationFeaturesToApplicationForm < ActiveRecord::Migration[
  8.0
]
  def change
    add_column :application_forms,
               :includes_prioritisation_features,
               :boolean,
               null: false,
               default: false
  end
end
