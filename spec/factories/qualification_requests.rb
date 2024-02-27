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
FactoryBot.define do
  factory :qualification_request do
    association :assessment
    association :qualification, :completed

    trait :consent_method_signed do
      consent_method { %i[signed_ecctis signed_institution].sample }
    end

    trait :requested do
      requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :received do
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
      receivable
    end

    trait :expired do
      expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :receivable do
      location_note { Faker::Lorem.sentence }
    end
  end
end
