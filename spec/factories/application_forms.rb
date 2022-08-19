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
#  has_work_history        :boolean
#  reference               :string(31)       not null
#  registration_number     :text
#  status                  :string           default("active"), not null
#  subjects                :text             default([]), not null, is an Array
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  region_id               :bigint           not null
#  teacher_id              :bigint           not null
#
# Indexes
#
#  index_application_forms_on_reference   (reference) UNIQUE
#  index_application_forms_on_region_id   (region_id)
#  index_application_forms_on_status      (status)
#  index_application_forms_on_teacher_id  (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
FactoryBot.define do
  factory :application_form do
    sequence(:reference) { |n| n.to_s.rjust(7, "0") }
    status { "active" }
    association :teacher
    association :region, :national

    trait :submitted do
      status { "submitted" }
    end

    trait :with_age_range do
      age_range_min { Faker::Number.between(from: 5, to: 11) }
      age_range_max { Faker::Number.between(from: age_range_min, to: 18) }
    end

    trait :with_subjects do
      transient { number_of_subjects { Faker::Number.between(from: 1, to: 3) } }

      subjects do
        ([-> { Faker::Educator.subject }] * number_of_subjects).map(&:call)
      end
    end

    trait :with_identification_document do
      identification_document do
        build(:document, :identification_document, :with_upload)
      end
    end

    trait :with_personal_information do
      given_names { Faker::Name.name }
      family_name { Faker::Name.last_name }
      date_of_birth do
        Faker::Date.between(from: 65.years.ago, to: 21.years.ago)
      end
    end

    trait :with_registration_number do
      registration_number do
        Faker::Number.unique.leading_zero_number(digits: 8)
      end
    end

    trait :with_completed_qualification do
      after(:create) do |application_form, _evaluator|
        application_form.qualifications << build(:qualification, :completed)
      end
    end

    trait :with_work_history do
      has_work_history { true }
    end

    trait :with_written_statement do
      written_statement_document do
        build(:document, :written_statement, :with_upload)
      end
    end
  end
end
