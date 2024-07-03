# frozen_string_literal: true

class AddUuidToTeacher < ActiveRecord::Migration[7.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    add_column :teachers,
               :uuid,
               :uuid,
               default: "gen_random_uuid()",
               null: false

    add_index :teachers, :uuid, unique: true
  end
end
