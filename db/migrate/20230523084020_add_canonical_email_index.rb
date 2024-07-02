# frozen_string_literal: true

class AddCanonicalEmailIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :teachers, :canonical_email, algorithm: :concurrently
    add_index :work_histories,
              :canonical_contact_email,
              algorithm: :concurrently
  end
end
