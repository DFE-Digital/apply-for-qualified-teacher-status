#frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_request_items
#
#  id                               :bigint           not null, primary key
#  failure_reason_assessor_feedback :text
#  failure_reason_key               :string           default(""), not null
#  information_type                 :string
#  response                         :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  further_information_request_id   :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id  (further_information_request_id)
#
FactoryBot.define do
  factory :further_information_request_item do
    association :further_information_request
    failure_reason_assessor_feedback { Faker::Lorem.paragraph }

    trait :with_text_response do
      information_type { "text" }
      failure_reason_key { "qualifications_dont_match_subjects" }
    end

    trait :with_document_response do
      information_type { "document" }
      failure_reason_key { "identification_document_illegible" }

      after(:create) do |item|
        create(:document, :identification, documentable: item)
      end
    end

    trait :completed do
      response { Faker::Lorem.paragraph if text? }

      after(:create) do |item, _evaluator|
        create(:upload, document: item.document) if item.document?
      end
    end
  end
end
