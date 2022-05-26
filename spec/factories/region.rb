FactoryBot.define do
  factory :region do
    association :country

    sequence(:name) { |n| "Region #{n}" }

    trait :national do
      name { "" }
    end
  end
end
