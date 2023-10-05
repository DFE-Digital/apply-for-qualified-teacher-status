# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id                    :bigint           not null, primary key
#  expired_at            :datetime
#  failure_assessor_note :string           default(""), not null
#  location_note         :text             default(""), not null
#  passed                :boolean
#  received_at           :datetime
#  requested_at          :datetime
#  reviewed_at           :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_id         :bigint           not null
#  qualification_id      :bigint           not null
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
