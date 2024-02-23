# frozen_string_literal: true

# == Schema Information
#
# Table name: consent_requests
#
#  id                           :bigint           not null, primary key
#  expired_at                   :datetime
#  received_at                  :datetime
#  requested_at                 :datetime
#  unsigned_document_downloaded :boolean          default(FALSE), not null
#  verified_at                  :datetime
#  verify_note                  :text             default(""), not null
#  verify_passed                :boolean
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  assessment_id                :bigint           not null
#  qualification_id             :bigint           not null
#
# Indexes
#
#  index_consent_requests_on_assessment_id     (assessment_id)
#  index_consent_requests_on_qualification_id  (qualification_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (qualification_id => qualifications.id)
#
class ConsentRequest < ApplicationRecord
  ATTACHABLE_DOCUMENT_TYPES = %w[signed_consent unsigned_consent].freeze

  include Documentable
  include Requestable

  belongs_to :qualification

  scope :order_by_role,
        -> { joins(:qualification).order("qualifications.start_date": :desc) }
  scope :order_by_user,
        -> { joins(:qualification).order("qualifications.created_at": :asc) }

  def expires_after
    6.weeks
  end
end
