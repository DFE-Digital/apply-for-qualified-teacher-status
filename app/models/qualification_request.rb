# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id               :bigint           not null, primary key
#  consent_method   :string           default("unknown"), not null
#  expired_at       :datetime
#  location_note    :text             default(""), not null
#  received_at      :datetime
#  requested_at     :datetime
#  review_note      :string           default(""), not null
#  review_passed    :boolean
#  reviewed_at      :datetime
#  verified_at      :datetime
#  verify_note      :text             default(""), not null
#  verify_passed    :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assessment_id    :bigint           not null
#  qualification_id :bigint           not null
#
# Indexes
#
#  index_qualification_requests_on_assessment_id     (assessment_id)
#  index_qualification_requests_on_qualification_id  (qualification_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (qualification_id => qualifications.id)
#
class QualificationRequest < ApplicationRecord
  include Requestable

  belongs_to :qualification

  enum consent_method: {
         signed_ecctis: "signed_ecctis",
         signed_institution: "signed_institution",
         unknown: "unknown",
         unsigned: "unsigned",
       },
       _prefix: true

  scope :order_by_role,
        -> { joins(:qualification).order("qualifications.start_date": :desc) }
  scope :order_by_user,
        -> { joins(:qualification).order("qualifications.created_at": :asc) }

  def expires_after
    6.weeks
  end

  def consent_method_signed?
    consent_method_signed_ecctis? || consent_method_signed_institution?
  end
end
