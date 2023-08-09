# == Schema Information
#
# Table name: teachers
#
#  id                 :bigint           not null, primary key
#  canonical_email    :text             default(""), not null
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string           default(""), not null
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  sign_in_count      :integer          default(0), not null
#  trn                :string
#  uuid               :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
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
  end
end
