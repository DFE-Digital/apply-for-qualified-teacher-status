FactoryBot.define do
  factory :country do
    sequence :code, Country::COUNTRY_CODES.cycle

    legacy { false }

    trait :legacy do
      legacy { true }
    end
  end
end
