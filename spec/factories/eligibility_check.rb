FactoryBot.define do
  factory :eligibility_check do
    country_code { nil }
    degree { nil }
    free_of_sanctions { nil }
    qualification { nil }
    teach_children { nil }

    trait :eligible do
      association :region
      degree { true }
      free_of_sanctions { true }
      qualification { true }
      teach_children { true }

      after(:create) do |eligiblity_check, _evaluator|
        eligiblity_check.country_code = eligiblity_check.region.country.code
      end
    end

    trait :complete do
      completed_at { Time.current }
    end

    trait :ineligible do
      degree { false }
    end
  end
end
