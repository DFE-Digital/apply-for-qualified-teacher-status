class AddRequestedAtToRequestables < ActiveRecord::Migration[7.0]
  def change
    add_column :further_information_requests, :requested_at, :datetime
    add_column :professional_standing_requests, :requested_at, :datetime
    add_column :qualification_requests, :requested_at, :datetime
    add_column :reference_requests, :requested_at, :datetime

    FurtherInformationRequest.update_all("requested_at = created_at")
    ProfessionalStandingRequest.update_all("requested_at = created_at")
    QualificationRequest.update_all("requested_at = created_at")
    ReferenceRequest.update_all("requested_at = created_at")
  end
end
