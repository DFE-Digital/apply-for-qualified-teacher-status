# == Schema Information
#
# Table name: countries
#
#  id                             :bigint           not null, primary key
#  code                           :string           not null
#  teaching_authority_address     :text             default(""), not null
#  teaching_authority_certificate :text             default(""), not null
#  teaching_authority_emails      :text             default([]), not null, is an Array
#  teaching_authority_other       :text             default(""), not null
#  teaching_authority_websites    :text             default([]), not null, is an Array
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
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
