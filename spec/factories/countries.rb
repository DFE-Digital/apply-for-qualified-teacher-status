# == Schema Information
#
# Table name: countries
#
#  id                                      :bigint           not null, primary key
#  code                                    :string           not null
#  eligibility_enabled                     :boolean          default(TRUE), not null
#  eligibility_skip_questions              :boolean          default(FALSE), not null
#  qualifications_information              :text             default(""), not null
#  requires_preliminary_check              :boolean          default(FALSE), not null
#  teaching_authority_address              :text             default(""), not null
#  teaching_authority_certificate          :text             default(""), not null
#  teaching_authority_emails               :text             default([]), not null, is an Array
#  teaching_authority_name                 :text             default(""), not null
#  teaching_authority_online_checker_url   :string           default(""), not null
#  teaching_authority_other                :text             default(""), not null
#  teaching_authority_sanction_information :string           default(""), not null
#  teaching_authority_status_information   :string           default(""), not null
#  teaching_authority_websites             :text             default([]), not null, is an Array
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
FactoryBot.define do
  factory :country do
    sequence :code, Country::CODES.cycle

    trait :requires_secondary_education_teaching_qualification do
      sequence :code,
               Country::CODES_REQUIRING_SECONDARY_EDUCATION_TEACHING_QUALIFICATION.cycle
    end

    trait :doesnt_require_secondary_education_teaching_qualification do
      sequence :code,
               (
                 Country::CODES -
                   Country::CODES_REQUIRING_SECONDARY_EDUCATION_TEACHING_QUALIFICATION
               ).cycle
    end

    trait :with_national_region do
      after(:create) do |country, _evaluator|
        create(:region, :national, country:)
      end
    end

    trait :with_teaching_authority do
      teaching_authority_address { Faker::Address.street_address }
      teaching_authority_emails { [Faker::Internet.email] }
      teaching_authority_websites { [Faker::Internet.url] }
    end

    trait :requires_preliminary_check do
      requires_preliminary_check { true }
    end
  end
end
