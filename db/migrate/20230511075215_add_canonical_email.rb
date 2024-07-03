# frozen_string_literal: true

class AddCanonicalEmail < ActiveRecord::Migration[7.0]
  def change
    add_column :teachers, :canonical_email, :text, default: "", null: false
    add_column :work_histories,
               :canonical_contact_email,
               :text,
               default: "",
               null: false
  end
end
