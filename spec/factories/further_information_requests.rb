# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id                                      :bigint           not null, primary key
#  failure_assessor_note                   :string           default(""), not null
#  passed                                  :boolean
#  received_at                             :datetime
#  state                                   :string           not null
#  working_days_received_to_recommendation :integer
#  working_days_since_received             :integer
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  assessment_id                           :bigint
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

    trait :passed do
      passed { true }
    end

    trait :failed do
      passed { false }
      failure_assessor_note { "Notes." }
    end

    trait :expired do
      state { "expired" }
    end

    trait :with_items do
      after(:create) do |further_information_request, _evaluator|
        create(
          :further_information_request_item,
          :with_text_response,
          further_information_request:,
        )
        create(
          :further_information_request_item,
          :with_document_response,
          further_information_request:,
        )
      end
    end
  end
end
