FactoryBot.define do
  factory :country do
    sequence :code, Country::COUNTRIES.keys.cycle

    trait :with_national_region do
      after(:create) do |country, _evaluator|
        create(:region, :national, country:)
      end
    end

    trait :with_legacy_region do
      after(:create) do |country, _evaluator|
        create(:region, :legacy, country:)
      end
    end
  end
end
