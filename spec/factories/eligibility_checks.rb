# == Schema Information
#
# Table name: eligibility_checks
#
#  id                     :bigint           not null, primary key
#  completed_at           :datetime
#  completed_requirements :boolean
#  country_code           :string
#  degree                 :boolean
#  free_of_sanctions      :boolean
#  qualification          :boolean
#  teach_children         :boolean
#  work_experience        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  region_id              :bigint
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
FactoryBot.define do
  factory :eligibility_check do
    country_code { nil }
    completed_requirements { nil }
    degree { nil }
    free_of_sanctions { nil }
    qualification { nil }
    teach_children { nil }

    trait :eligible do
      association :region
      completed_requirements { true }
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

    trait :new_regs do
      created_at { Date.new(2023, 2, 1) }
    end
  end
end
