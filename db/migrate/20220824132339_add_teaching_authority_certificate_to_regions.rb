# frozen_string_literal: true

class AddTeachingAuthorityCertificateToRegions < ActiveRecord::Migration[7.0]
  def change
    add_column :regions,
               :teaching_authority_certificate,
               :text,
               default: "",
               null: false
  end
end
