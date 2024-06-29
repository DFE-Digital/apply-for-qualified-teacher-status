# frozen_string_literal: true

class AddTeachingAuthorityOtherToRegion < ActiveRecord::Migration[7.0]
  def change
    add_column :regions,
               :teaching_authority_other,
               :text,
               default: "",
               null: false
  end
end
