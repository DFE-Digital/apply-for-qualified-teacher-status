class AddExpiredAtToRequestables < ActiveRecord::Migration[7.0]
  def change
    add_column :further_information_requests, :expired_at, :datetime
    add_column :professional_standing_requests, :expired_at, :datetime
    add_column :qualification_requests, :expired_at, :datetime
    add_column :reference_requests, :expired_at, :datetime

    FurtherInformationRequest.expired.each do |requestable|
      requestable.update!(expired_at: requestable.expires_at)
    end

    ProfessionalStandingRequest.expired.each do |requestable|
      requestable.update!(expired_at: requestable.expires_at)
    end

    QualificationRequest.expired.each do |requestable|
      requestable.update!(expired_at: requestable.expires_at)
    end

    ReferenceRequest.expired.each do |requestable|
      requestable.update!(expired_at: requestable.expires_at)
    end
  end
end
