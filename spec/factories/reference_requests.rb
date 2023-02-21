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
#  hours_comment                   :text             default(""), not null
#  hours_response                  :boolean
#  lessons_comment                 :text             default(""), not null
#  lessons_response                :boolean
#  misconduct_comment              :text             default(""), not null
#  misconduct_response             :boolean
#  passed                          :boolean
#  received_at                     :datetime
#  reports_comment                 :text             default(""), not null
#  reports_response                :boolean
#  reviewed_at                     :datetime
#  satisfied_comment               :text             default(""), not null
#  satisfied_response              :boolean
#  slug                            :string           not null
#  state                           :string           not null
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
    association :work_history, :completed

    trait :requested do
      state { "requested" }
    end

    trait :received do
      state { "received" }
      received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
      receivable
    end

    trait :expired do
      state { "expired" }
    end

    trait :passed do
      passed { true }
      reviewed_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
      received
    end

    trait :receivable do
      contact_response { Faker::Boolean.boolean }
      dates_response { Faker::Boolean.boolean }
      hours_response { Faker::Boolean.boolean }
      children_response { Faker::Boolean.boolean }
      lessons_response { Faker::Boolean.boolean }
      reports_response { Faker::Boolean.boolean }
      misconduct_response { Faker::Boolean.boolean }
      satisfied_response { Faker::Boolean.boolean }
      additional_information_response { Faker::Lorem.sentence }
    end

    trait :responses_invalid do
      contact_response { false }
      dates_response { false }
      hours_response { false }
      children_response { false }
      lessons_response { false }
      reports_response { false }
      misconduct_response { false }
      satisfied_response { false }
    end

    trait :responses_valid do
      contact_response { true }
      dates_response { true }
      hours_response { true }
      children_response { true }
      lessons_response { true }
      reports_response { true }
      misconduct_response { true }
      satisfied_response { true }
    end
  end
end
