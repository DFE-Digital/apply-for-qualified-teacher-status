class RemoveReadyForReviewFromProfessionalStandingRequests < ActiveRecord::Migration[
  7.1
]
  def change
    remove_column :professional_standing_requests,
                  :ready_for_review,
                  :boolean,
                  null: false,
                  default: false
  end
end
