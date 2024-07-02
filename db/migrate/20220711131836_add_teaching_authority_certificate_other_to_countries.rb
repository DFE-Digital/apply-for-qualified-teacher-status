# frozen_string_literal: true

class AddTeachingAuthorityCertificateOtherToCountries < ActiveRecord::Migration[
  7.0
]
  def change
    change_table :countries, bulk: true do |t|
      t.column :teaching_authority_certificate, :text, default: "", null: false
      t.column :teaching_authority_other, :text, default: "", null: false
    end

    regions_to_update =
      Region
        .includes(:country)
        .where.not(teaching_authority_certificate: "")
        .or(Region.where.not(teaching_authority_other: ""))

    regions_to_update.find_each do |region|
      region.country.update!(
        {
          teaching_authority_certificate: region.teaching_authority_certificate,
          teaching_authority_other: region.teaching_authority_other,
        }.compact_blank,
      )
    end
  end
end
