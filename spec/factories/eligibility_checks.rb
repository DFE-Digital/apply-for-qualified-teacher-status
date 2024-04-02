# == Schema Information
#
# Table name: eligibility_checks
#
#  id                    :bigint           not null, primary key
#  completed_at          :datetime
#  country_code          :string
#  degree                :boolean
#  free_of_sanctions     :boolean
#  qualification         :boolean
#  qualified_for_subject :boolean
#  teach_children        :boolean
#  work_experience       :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  region_id             :bigint
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
FactoryBot.define do
  factory :eligibility_check do
    country_code { nil }
    degree { nil }
    free_of_sanctions { nil }
    qualification { nil }
    teach_children { nil }
    work_experience { nil }
    qualified_for_subject { nil }

    trait :eligible do
      region
      country_code { region.country.code }
      degree { true }
      free_of_sanctions { true }
      qualification { true }
      teach_children { true }
      work_experience { "over_20_months" }
      qualified_for_subject { true }
    end

    trait :complete do
      completed_at { Time.current }
    end

    trait :ineligible do
      degree { false }
    end
  end
end
