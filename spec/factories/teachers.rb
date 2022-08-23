# == Schema Information
#
# Table name: teachers
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  current_sign_in_at   :datetime
#  current_sign_in_ip   :string
#  email                :string           default(""), not null
#  last_sign_in_at      :datetime
#  last_sign_in_ip      :string
#  sign_in_count        :integer          default(0), not null
#  unconfirmed_email    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_teachers_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :teacher do
    sequence(:email) { |n| "teacher#{n}@example.org" }

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end
  end
end
