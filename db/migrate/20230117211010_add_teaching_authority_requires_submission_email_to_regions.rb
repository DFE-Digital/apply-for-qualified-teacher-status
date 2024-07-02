# frozen_string_literal: true

class AddTeachingAuthorityRequiresSubmissionEmailToRegions < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :regions,
               :teaching_authority_requires_submission_email,
               :boolean,
               default: false,
               null: false
  end
end
