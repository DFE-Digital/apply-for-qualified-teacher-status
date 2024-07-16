# frozen_string_literal: true

class AddCreatedByToSuitabilityRecords < ActiveRecord::Migration[7.1]
  def change
    # rubocop:disable Rails/NotNullColumn
    add_reference :suitability_records,
                  :created_by,
                  foreign_key: {
                    to_table: :staff,
                  },
                  null: false
    # rubocop:enable Rails/NotNullColumn
  end
end
