# frozen_string_literal: true

# == Schema Information
#
# Table name: reference_requests
#
#  id                              :bigint           not null, primary key
#  additional_information_response :text             default(""), not null
#  children_response               :boolean
#  dates_response                  :boolean
#  hours_response                  :boolean
#  lessons_response                :boolean
#  passed                          :boolean
#  received_at                     :datetime
#  reports_response                :boolean
#  reviewed_at                     :datetime
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

    trait :receivable do
      dates_response { Faker::Boolean.boolean }
      hours_response { Faker::Boolean.boolean }
      children_response { Faker::Boolean.boolean }
      lessons_response { Faker::Boolean.boolean }
      reports_response { Faker::Boolean.boolean }
      additional_information_response { Faker::Lorem.sentence }
    end

    trait :responses_invalid do
      dates_response { false }
      hours_response { false }
      children_response { false }
      lessons_response { false }
      reports_response { false }
    end

    trait :responses_valid do
      dates_response { true }
      hours_response { true }
      children_response { true }
      lessons_response { true }
      reports_response { true }
    end
  end
end
