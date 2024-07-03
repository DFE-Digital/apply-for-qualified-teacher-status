# frozen_string_literal: true

class AddFailureAssessorNoteToProfessionalStandingRequest < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :professional_standing_requests,
               :failure_assessor_note,
               :string,
               default: "",
               null: false
  end
end
