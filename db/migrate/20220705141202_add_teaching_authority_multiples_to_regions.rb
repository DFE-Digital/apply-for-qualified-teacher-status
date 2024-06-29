# frozen_string_literal: true

class AddTeachingAuthorityMultiplesToRegions < ActiveRecord::Migration[7.0]
  def up
    change_table :regions, bulk: true do |t|
      t.column :teaching_authority_emails,
               :text,
               default: [],
               null: false,
               array: true
      t.column :teaching_authority_websites,
               :text,
               default: [],
               null: false,
               array: true
    end

    regions_to_update =
      Region
        .where.not(teaching_authority_email_address: "")
        .or(Region.where.not(teaching_authority_website: ""))

    regions_to_update.find_each do |region|
      region.update!(
        teaching_authority_emails: [
          region.teaching_authority_email_address,
        ].compact_blank,
        teaching_authority_websites: [
          region.teaching_authority_website,
        ].compact_blank,
      )
    end
  end

  def down
    change_table :regions, bulk: true do |t|
      t.remove :teaching_authority_websites, :teaching_authority_emails
    end
  end
end
