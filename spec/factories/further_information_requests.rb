# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id            :bigint           not null, primary key
#  received_at   :datetime
#  state         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assessment_id :bigint
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
FactoryBot.define do
  factory :further_information_request do
    association :assessment

    trait :requested do
      state { "requested" }
    end

    trait :received do
      state { "received" }
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end
  end
end
