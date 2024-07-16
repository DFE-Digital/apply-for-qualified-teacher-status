# frozen_string_literal: true

# == Schema Information
#
# Table name: suitability_records
#
#  id            :bigint           not null, primary key
#  archive_note  :text             default(""), not null
#  archived_at   :datetime
#  country_code  :text             default(""), not null
#  date_of_birth :date
#  note          :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#
# Indexes
#
#  index_suitability_records_on_created_by_id  (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => staff.id)
#
FactoryBot.define do
  factory :suitability_record do
    association :created_by, factory: :staff

    note { Faker::Lorem.sentence }

    trait :archived do
      archived_at { Time.zone.now }
      archive_note { Faker::Lorem.sentence }
    end
  end

  factory :suitability_record_email, class: SuitabilityRecord::Email do
    association :suitability_record

    value { Faker::Internet.email }
    canonical { EmailAddress.canonical(value) }
  end

  factory :suitability_record_name, class: SuitabilityRecord::Name do
    association :suitability_record

    value { Faker::Name.name }
  end
end
