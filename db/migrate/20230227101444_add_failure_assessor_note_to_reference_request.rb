# frozen_string_literal: true

class AddFailureAssessorNoteToReferenceRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :reference_requests,
               :failure_assessor_note,
               :string,
               default: "",
               null: false
  end
end
