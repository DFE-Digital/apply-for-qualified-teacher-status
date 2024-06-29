# frozen_string_literal: true

class AddReducedEvidenceAccepted < ActiveRecord::Migration[7.0]
  def change
    add_column :regions,
               :reduced_evidence_accepted,
               :boolean,
               default: false,
               null: false
    add_column :application_forms,
               :reduced_evidence_accepted,
               :boolean,
               default: false,
               null: false
  end
end
