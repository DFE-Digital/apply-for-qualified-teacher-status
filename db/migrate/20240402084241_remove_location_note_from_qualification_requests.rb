# frozen_string_literal: true

class RemoveLocationNoteFromQualificationRequests < ActiveRecord::Migration[7.1]
  def change
    remove_column :qualification_requests,
                  :location_note,
                  :text,
                  default: "",
                  null: false
  end
end
