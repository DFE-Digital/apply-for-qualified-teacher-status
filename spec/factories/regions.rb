# == Schema Information
#
# Table name: regions
#
#  id                          :bigint           not null, primary key
#  legacy                      :boolean          default(TRUE), not null
#  name                        :string           default(""), not null
#  sanction_check              :string           default("none"), not null
#  status_check                :string           default("none"), not null
#  teaching_authority_address  :text             default(""), not null
#  teaching_authority_emails   :text             default([]), not null, is an Array
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
  end
end
