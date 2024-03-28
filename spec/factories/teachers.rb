# == Schema Information
#
# Table name: teachers
#
#  id                                      :bigint           not null, primary key
#  access_your_teaching_qualifications_url :string
#  canonical_email                         :text             default(""), not null
#  current_sign_in_at                      :datetime
#  current_sign_in_ip                      :string
#  email                                   :string           not null
#  email_domain                            :text             default(""), not null
#  last_sign_in_at                         :datetime
#  last_sign_in_ip                         :string
#  sign_in_count                           :integer          default(0), not null
#  trn                                     :string
#  uuid                                    :uuid             not null
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#
# Indexes
#
#  index_teacher_on_lower_email       (lower((email)::text)) UNIQUE
#  index_teachers_on_canonical_email  (canonical_email)
#  index_teachers_on_uuid             (uuid) UNIQUE
#
FactoryBot.define do
  factory :teacher do
    sequence(:email) { |n| "teacher#{n}@example.org" }
    uuid { SecureRandom.uuid }
    canonical_email { EmailAddress.canonical(email) }

    trait :with_trn do
      trn { Faker::Number.leading_zero_number(digits: 6) }
    end

    trait :with_access_your_teaching_qualifications_url do
      access_your_teaching_qualifications_url { Faker::Internet.url }
    end
  end
end
