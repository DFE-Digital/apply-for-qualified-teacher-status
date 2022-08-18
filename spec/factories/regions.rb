# == Schema Information
#
# Table name: regions
#
#  id                          :bigint           not null, primary key
#  application_form_enabled    :boolean          default(FALSE)
#  legacy                      :boolean          default(TRUE), not null
#  name                        :string           default(""), not null
#  sanction_check              :string           default("none"), not null
#  status_check                :string           default("none"), not null
#  teaching_authority_address  :text             default(""), not null
#  teaching_authority_emails   :text             default([]), not null, is an Array
#  teaching_authority_name     :text             default(""), not null
#  teaching_authority_other    :text             default(""), not null
#  teaching_authority_websites :text             default([]), not null, is an Array
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  country_id                  :bigint           not null
#
# Indexes
#
#  index_regions_on_country_id           (country_id)
#  index_regions_on_country_id_and_name  (country_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
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

    trait :application_form_enabled do
      application_form_enabled { true }
    end

    trait :online_checks do
      sanction_check { :online }
      status_check { :online }
    end

    trait :written_checks do
      sanction_check { :written }
      status_check { :written }
    end

    trait :none_checks do
      sanction_check { :none }
      status_check { :none }
    end

    trait :with_teaching_authority do
      teaching_authority_address { Faker::Address.street_address }
      teaching_authority_emails { [Faker::Internet.email] }
      teaching_authority_websites { [Faker::Internet.url] }
    end
  end
end
