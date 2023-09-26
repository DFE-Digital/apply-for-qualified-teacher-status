# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id                    :bigint           not null, primary key
#  expired_at            :datetime
#  failure_assessor_note :string           default(""), not null
#  location_note         :text             default(""), not null
#  passed                :boolean
#  ready_for_review      :boolean          default(FALSE), not null
#  received_at           :datetime
#  requested_at          :datetime
#  reviewed_at           :datetime
#  state                 :string           default("requested"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_id         :bigint           not null
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

    requested

    trait :requested do
      state { "requested" }
      requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :received do
      state { "received" }
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
      receivable
    end

    trait :expired do
      state { "expired" }
      expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :receivable do
      location_note { Faker::Lorem.sentence }
    end
  end
end
