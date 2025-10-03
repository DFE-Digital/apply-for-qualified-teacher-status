# frozen_string_literal: true

class AddForeignKeyForNotesEligibilityDomains < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :notes, :eligibility_domains
  end
end
