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

FactoryBot.define do
  factory :decision_review_request do
    assessment

    comment { Faker::Lorem.sentence }
    has_supporting_documents { true }

    factory :received_decision_review_request, traits: %i[received]
  end
end
