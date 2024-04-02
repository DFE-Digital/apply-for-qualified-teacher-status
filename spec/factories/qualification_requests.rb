# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id               :bigint           not null, primary key
#  consent_method   :string           default("unknown"), not null
#  expired_at       :datetime
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
FactoryBot.define do
  factory :qualification_request do
    assessment

    qualification do
      create(
        :qualification,
        :completed,
        application_form: assessment.application_form,
      )
    end

    trait :with_consent_method do
      consent_method { %i[signed_ecctis signed_institution unsigned].sample }
    end
  end
end
