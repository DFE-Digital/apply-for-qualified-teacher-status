FactoryBot.define do
  factory :region do
    association :country

    sequence(:name) { |n| "Region #{n}" }
    legacy { false }

    trait :national do
      name { "" }
    end

    trait :legacy do
      legacy { true }
    end
  end
end
