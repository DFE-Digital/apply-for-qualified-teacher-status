# frozen_string_literal: true

# == Schema Information
#
# Table name: decision_review_requests
#
#  id                       :bigint           not null, primary key
#  comment                  :text             default(""), not null
#  has_supporting_documents :boolean
#  received_at              :datetime
#  review_note              :text             default(""), not null
#  review_passed            :boolean
#  reviewed_at              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  assessment_id            :bigint           not null
#
# Indexes
#
#  index_decision_review_requests_on_assessment_id  (assessment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
class DecisionReviewRequest < ApplicationRecord
  ATTACHABLE_DOCUMENT_TYPES = %w[decision_review_evidence].freeze

  include Requestable
  include Documentable

  def completed?
    (comment.present? && has_supporting_documents == false) ||
      (
        comment.present? && has_supporting_documents == true &&
          decision_review_evidence_document.completed?
      )
  end

  def after_received(user:)
    # We may want to trigger email delivery
  end

  def after_reviewed(user:)
    # We may want to also trigger email delivery
    RollbackAssessment.call(assessment:, user:) if review_passed
  end
end
