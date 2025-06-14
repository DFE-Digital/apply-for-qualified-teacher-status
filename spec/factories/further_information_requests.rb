# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id                                                   :bigint           not null, primary key
#  expired_at                                           :datetime
#  received_at                                          :datetime
#  requested_at                                         :datetime
#  review_note                                          :string           default(""), not null
#  review_passed                                        :boolean
#  reviewed_at                                          :datetime
#  working_days_between_assessment_started_to_requested :integer
#  created_at                                           :datetime         not null
#  updated_at                                           :datetime         not null
#  assessment_id                                        :bigint           not null
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
FactoryBot.define do
  factory :further_information_request do
    assessment

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
        )
        create(
          :further_information_request_item,
          :with_document_response,
          further_information_request:,
        )
      end
    end

    factory :requested_further_information_request, traits: %i[requested]
    factory :received_further_information_request,
            traits: %i[requested received]
  end
end
