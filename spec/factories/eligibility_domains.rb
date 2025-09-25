# frozen_string_literal: true

# == Schema Information
#
# Table name: eligibility_domains
#
#  id                      :bigint           not null, primary key
#  application_forms_count :integer
#  archived_at             :datetime
#  domain                  :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  created_by_id           :bigint           not null
#
# Indexes
#
#  index_eligibility_domains_on_created_by_id  (created_by_id)
#  index_eligibility_domains_on_domain         (domain) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => staff.id)
#
FactoryBot.define do
  factory :eligibility_domain do
    association :created_by, factory: :staff

    domain { Faker::Internet.domain_name }

    trait :archived do
      archived_at { Time.zone.now }
    end
  end
end
