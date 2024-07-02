# frozen_string_literal: true

class RemoveTeachingAuthorityCertificateOtherFromRegions < ActiveRecord::Migration[
  7.0
]
  def up
    change_table :regions, bulk: true do |t|
      t.remove :teaching_authority_certificate, :teaching_authority_other
    end
  end

  def down
    change_table :regions, bulk: true do |t|
      t.column :teaching_authority_certificate, :text, default: "", null: false
      t.column :teaching_authority_other, :text, default: "", null: false
    end
  end
end
