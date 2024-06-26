# frozen_string_literal: true

# == Schema Information
#
# Table name: consent_requests
#
#  id                           :bigint           not null, primary key
#  expired_at                   :datetime
#  received_at                  :datetime
#  requested_at                 :datetime
#  review_note                  :text             default(""), not null
#  review_passed                :boolean
#  reviewed_at                  :datetime
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
FactoryBot.define do
  factory :consent_request do
    assessment

    qualification do
      create(
        :qualification,
        :completed,
        application_form: assessment.application_form,
      )
    end

    trait :with_unsigned_upload do
      after(:create) do |consent_request, _evaluator|
        create(:upload, document: consent_request.unsigned_consent_document)
      end
    end

    trait :with_signed_upload do
      after(:create) do |consent_request, _evaluator|
        create(:upload, document: consent_request.signed_consent_document)
      end
    end

    factory :requested_consent_request,
            traits: %i[with_unsigned_upload requested]
    factory :received_consent_request,
            traits: %i[
              with_unsigned_upload
              requested
              with_signed_upload
              received
            ]
  end
end
