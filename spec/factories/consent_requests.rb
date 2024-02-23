# frozen_string_literal: true

FactoryBot.define do
  factory :consent_request do
    association :assessment
    association :qualification, :completed

    trait :with_unsigned_upload do
      after(:create) do |consent_request, _evaluator|
        create(:upload, document: consent_request.unsigned_consent_document)
      end
    end

    trait :with_signed_upload do
      after(:create) do |consent_request, _evaluator|
        create(:upload, document: consent_request.signed_consent_document)
      end
    end

    trait :requested do
      with_unsigned_upload
      requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :received do
      requested
      with_signed_upload
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :expired do
      requested
      expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end
  end
end
