# frozen_string_literal: true

class AddArchivedByToSuitabilityRecords < ActiveRecord::Migration[7.1]
  def change
    add_reference :suitability_records,
                  :archived_by,
                  foreign_key: {
                    to_table: :staff,
                  }
  end
end
