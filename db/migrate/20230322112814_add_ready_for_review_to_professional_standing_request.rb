# frozen_string_literal: true

class AddReadyForReviewToProfessionalStandingRequest < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :professional_standing_requests,
               :ready_for_review,
               :boolean,
               default: false,
               null: false
  end
end
