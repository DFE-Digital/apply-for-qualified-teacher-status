# frozen_string_literal: true

class CreateEligibilityDomains < ActiveRecord::Migration[8.0]
  def change
    create_table :eligibility_domains do |t|
      t.string :domain
      t.datetime :archived_at
      t.integer :application_forms_count

      t.references :created_by, null: false, foreign_key: { to_table: :staff }

      t.timestamps
    end

    add_index :eligibility_domains, :domain, unique: true

    add_reference :work_histories, :eligibility_domain, foreign_key: true
    add_reference :timeline_events, :eligibility_domain, foreign_key: true
  end
end
