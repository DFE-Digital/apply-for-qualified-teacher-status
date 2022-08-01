# == Schema Information
#
# Table name: application_forms
#
#  id                      :bigint           not null, primary key
#  age_range_max           :integer
#  age_range_min           :integer
#  alternative_family_name :text             default(""), not null
#  alternative_given_names :text             default(""), not null
#  date_of_birth           :date
#  family_name             :text             default(""), not null
#  given_names             :text             default(""), not null
#  has_alternative_name    :boolean
#  reference               :string(31)       not null
#  status                  :string           default("active"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  eligibility_check_id    :bigint           not null
#  region_id               :bigint           not null
#  teacher_id              :bigint           not null
#
# Indexes
#
#  index_application_forms_on_eligibility_check_id  (eligibility_check_id)
#  index_application_forms_on_reference             (reference) UNIQUE
#  index_application_forms_on_region_id             (region_id)
#  index_application_forms_on_status                (status)
#  index_application_forms_on_teacher_id            (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (eligibility_check_id => eligibility_checks.id)
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
FactoryBot.define do
  factory :application_form do
    sequence(:reference) { |n| "ref#{n}" }
    status { "active" }
    association :teacher
    association :eligibility_check, :eligible
    association :region, :national

    trait :submitted do
      status { "submitted" }
    end

    trait :with_personal_information do
      given_names { "Given names" }
      family_name { "Family name" }
      date_of_birth { Date.new(2000, 1, 1) }
    end
  end
end
