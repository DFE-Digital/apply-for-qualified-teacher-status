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
#  state                   :string           default("draft"), not null
#  subjects                :text             default([]), not null, is an Array
#  submitted_at            :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  assessor_id             :bigint
#  region_id               :bigint           not null
#  reviewer_id             :bigint
#  teacher_id              :bigint           not null
#
# Indexes
#
#  index_application_forms_on_assessor_id  (assessor_id)
#  index_application_forms_on_family_name  (family_name)
#  index_application_forms_on_given_names  (given_names)
#  index_application_forms_on_reference    (reference) UNIQUE
#  index_application_forms_on_region_id    (region_id)
#  index_application_forms_on_reviewer_id  (reviewer_id)
#  index_application_forms_on_state        (state)
#  index_application_forms_on_teacher_id   (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessor_id => staff.id)
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (reviewer_id => staff.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
FactoryBot.define do
  factory :application_form do
    sequence(:reference) { |n| n.to_s.rjust(7, "0") }
    state { "draft" }
    association :teacher
    association :region, :national

    trait :submitted do
      state { "submitted" }
      submitted_at { Time.zone.now }
    end

    trait :awarded do
      state { "awarded" }
      submitted_at { Time.zone.now }
    end

    trait :declined do
      state { "declined" }
      submitted_at { Time.zone.now }
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
      after(:build) do |application_form, _evaluator|
        build(:upload, document: application_form.identification_document)
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

      after(:create) do |application_form, _evaluator|
        application_form.work_histories << build(:work_history, :completed)
      end
    end

    trait :with_written_statement do
      after(:build) do |application_form, _evaluator|
        build(:upload, document: application_form.written_statement_document)
      end
    end
  end
end
