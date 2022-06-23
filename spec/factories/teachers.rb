# == Schema Information
#
# Table name: teachers
#
#  id         :bigint           not null, primary key
#  email      :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teachers_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :teacher do
    email { "test@example.org" }
  end
end
