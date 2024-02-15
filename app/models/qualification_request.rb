# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id                                   :bigint           not null, primary key
#  consent_method                       :string           default("unknown"), not null
#  consent_received_at                  :datetime
#  consent_requested_at                 :datetime
#  expired_at                           :datetime
#  location_note                        :text             default(""), not null
#  received_at                          :datetime
#  requested_at                         :datetime
#  review_note                          :string           default(""), not null
#  review_passed                        :boolean
#  reviewed_at                          :datetime
#  unsigned_consent_document_downloaded :boolean          default(FALSE), not null
#  verified_at                          :datetime
#  verify_note                          :text             default(""), not null
#  verify_passed                        :boolean
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  assessment_id                        :bigint           not null
#  qualification_id                     :bigint           not null
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
  ATTACHABLE_DOCUMENT_TYPES = %w[signed_consent unsigned_consent].freeze

  include Documentable
  include Requestable

  belongs_to :qualification

  enum consent_method: {
         signed_ecctis: "signed_ecctis",
         signed_institution: "signed_institution",
         unknown: "unknown",
         unsigned: "unsigned",
       },
       _prefix: true

  scope :consent_required, -> { where(signed_consent_document_required: true) }
  scope :consent_requested, -> { where.not(consent_requested_at: nil) }
  scope :consent_received, -> { where.not(consent_received_at: nil) }
  scope :consent_respondable,
        -> do
          consent_requested
            .where(consent_received_at: nil)
            .joins(assessment: :application_form)
            .merge(ApplicationForm.assessable)
        end

  scope :order_by_role,
        -> { joins(:qualification).order("qualifications.start_date": :desc) }
  scope :order_by_user,
        -> { joins(:qualification).order("qualifications.created_at": :asc) }

  def expires_after
    6.weeks
  end

  def consent_requested!
    update!(consent_requested_at: Time.zone.now)
  end

  def consent_requested?
    consent_requested_at != nil
  end

  def consent_received!
    update!(consent_received_at: Time.zone.now)
  end

  def consent_received?
    consent_received_at != nil
  end
end
