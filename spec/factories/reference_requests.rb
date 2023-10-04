# frozen_string_literal: true

# == Schema Information
#
# Table name: reference_requests
#
#  id                              :bigint           not null, primary key
#  additional_information_response :text             default(""), not null
#  children_comment                :text             default(""), not null
#  children_response               :boolean
#  contact_comment                 :text             default(""), not null
#  contact_job                     :string           default(""), not null
#  contact_name                    :string           default(""), not null
#  contact_response                :boolean
#  dates_comment                   :text             default(""), not null
#  dates_response                  :boolean
#  expired_at                      :datetime
#  hours_comment                   :text             default(""), not null
#  hours_response                  :boolean
#  lessons_comment                 :text             default(""), not null
#  lessons_response                :boolean
#  misconduct_comment              :text             default(""), not null
#  misconduct_response             :boolean
#  received_at                     :datetime
#  reports_comment                 :text             default(""), not null
#  reports_response                :boolean
#  requested_at                    :datetime
#  review_note                     :string           default(""), not null
#  review_passed                   :boolean
#  reviewed_at                     :datetime
#  satisfied_comment               :text             default(""), not null
#  satisfied_response              :boolean
#  slug                            :string           not null
#  verified_at                     :datetime
#  verify_note                     :text             default(""), not null
#  verify_passed                   :boolean
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  assessment_id                   :bigint           not null
#  work_history_id                 :bigint           not null
#
# Indexes
#
#  index_reference_requests_on_assessment_id    (assessment_id)
#  index_reference_requests_on_slug             (slug) UNIQUE
#  index_reference_requests_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
FactoryBot.define do
  factory :reference_request do
    slug { Faker::Internet.unique.slug }

    association :assessment
    work_history do
      create(
        :work_history,
        :completed,
        application_form: assessment.application_form,
      )
    end

    trait :requested do
      requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :received do
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
      receivable
    end

    trait :expired do
      expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :reviewed do
      received
      reviewed_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    end

    trait :passed do
      reviewed
      review_passed { true }
    end

    trait :failed do
      reviewed
      review_passed { false }
      review_note { "Notes." }
    end

    trait :receivable do
      contact_response { Faker::Boolean.boolean }
      contact_name { contact_response ? "" : Faker::Name.name }
      contact_job { contact_response ? "" : Faker::Job.title }
      contact_comment { contact_response ? "" : Faker::Lorem.sentence }

      dates_response { Faker::Boolean.boolean }
      dates_comment { dates_response ? "" : Faker::Lorem.sentence }

      hours_response { Faker::Boolean.boolean }
      hours_comment { hours_response ? "" : Faker::Lorem.sentence }

      children_response { Faker::Boolean.boolean }
      children_comment { children_response ? "" : Faker::Lorem.sentence }

      lessons_response { Faker::Boolean.boolean }
      lessons_comment { lessons_response ? "" : Faker::Lorem.sentence }

      reports_response { Faker::Boolean.boolean }
      reports_comment { reports_response ? "" : Faker::Lorem.sentence }

      misconduct_response { Faker::Boolean.boolean }
      misconduct_comment { misconduct_response ? Faker::Lorem.sentence : "" }

      satisfied_response { Faker::Boolean.boolean }
      satisfied_comment { satisfied_response ? "" : Faker::Lorem.sentence }

      additional_information_response { Faker::Lorem.sentence }
    end

    trait :responses_invalid do
      contact_response { false }
      contact_name { Faker::Name.name }
      contact_job { Faker::Job.title }
      contact_comment { Faker::Lorem.sentence }
      dates_response { false }
      dates_comment { Faker::Lorem.sentence }
      hours_response { false }
      hours_comment { Faker::Lorem.sentence }
      children_response { false }
      children_comment { Faker::Lorem.sentence }
      lessons_response { false }
      lessons_comment { Faker::Lorem.sentence }
      reports_response { false }
      reports_comment { Faker::Lorem.sentence }
      misconduct_response { true }
      misconduct_comment { Faker::Lorem.sentence }
      satisfied_response { false }
      satisfied_comment { Faker::Lorem.sentence }
    end

    trait :responses_valid do
      contact_response { true }
      dates_response { true }
      hours_response { true }
      children_response { true }
      lessons_response { true }
      reports_response { true }
      misconduct_response { false }
      satisfied_response { true }
    end
  end
end
