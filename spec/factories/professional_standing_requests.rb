# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id               :bigint           not null, primary key
#  expired_at       :datetime
#  location_note    :text             default(""), not null
#  ready_for_review :boolean          default(FALSE), not null
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
#
# Indexes
#
#  index_professional_standing_requests_on_assessment_id  (assessment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
FactoryBot.define do
  factory :professional_standing_request do
    association :assessment

    trait :requested do
      requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :received do
      requested
      receivable
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :expired do
      requested
      expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :receivable do
      location_note { Faker::Lorem.sentence }
    end
  end
end
