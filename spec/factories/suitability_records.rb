# frozen_string_literal: true

FactoryBot.define do
  factory :suitability_record do
    note { Faker::Lorem.sentence }

    trait :archived do
      archived_at { Time.zone.now }
      archive_note { Faker::Lorem.sentence }
    end
  end

  factory :suitability_record_email do
    association :suitability_record

    value { Faker::Name.name }
  end

  factory :suitability_record_name do
    association :suitability_record

    value { Faker::Internet.email }
    canonical { EmailAddress.canonical(value) }
  end
end
