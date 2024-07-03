# frozen_string_literal: true

class AddFailureAssessorNoteToQualificationRequest < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :qualification_requests,
               :failure_assessor_note,
               :string,
               default: "",
               null: false
  end
end
