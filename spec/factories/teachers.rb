# == Schema Information
#
# Table name: teachers
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  email                :string           default(""), not null
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
  end
end
