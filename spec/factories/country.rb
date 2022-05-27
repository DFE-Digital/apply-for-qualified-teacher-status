FactoryBot.define do
  factory :country do
    sequence :code, Country::COUNTRIES.keys.cycle

    legacy { false }

    trait :legacy do
      legacy { true }
    end

    trait :with_national_region do
      after(:create) do |country, _evaluator|
        create(:region, :national, country:)
      end
    end
  end
end
