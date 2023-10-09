# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id                                          :bigint           not null, primary key
#  expired_at                                  :datetime
#  received_at                                 :datetime
#  requested_at                                :datetime
#  review_note                                 :string           default(""), not null
#  review_passed                               :boolean
#  reviewed_at                                 :datetime
#  working_days_assessment_started_to_creation :integer
#  working_days_received_to_recommendation     :integer
#  working_days_since_received                 :integer
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  assessment_id                               :bigint           not null
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
FactoryBot.define do
  factory :further_information_request do
    association :assessment

    trait :requested do
      requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :received do
      requested
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :expired do
      requested
      expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :reviewed do
      received
      reviewed_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :passed do
      reviewed
      review_passed { true }
    end

    trait :failed do
      reviewed
      review_passed { false }
      review_note { "Notes." }
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
          :with_work_history_contact_response,
          further_information_request:,
          work_history:
            create(
              :work_history,
              :completed,
              application_form: further_information_request.application_form,
            ),
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
