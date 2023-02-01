# frozen_string_literal: true

# == Schema Information
#
# Table name: english_language_providers
#
#  id                   :bigint           not null, primary key
#  accepted_tests       :string           default(""), not null
#  b2_level_requirement :text             not null
#  check_url            :string
#  name                 :string           not null
#  reference_hint       :text             not null
#  reference_name       :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
FactoryBot.define do
  factory :english_language_provider do
    name { Faker::Company.name }
    b2_level_requirement { Faker::Lorem.sentence }
    reference_name { Faker::Lorem.word }
    reference_hint { Faker::Lorem.sentence }
    accepted_tests { Faker::Lorem.sentence }
    check_url { Faker::Internet.url }
  end
end
