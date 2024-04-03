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
    assessment

    slug { Faker::Internet.unique.slug }

    work_history do
      create(
        :work_history,
        :completed,
        application_form: assessment.application_form,
      )
    end

    trait :with_responses do
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

    factory :requested_reference_request, traits: %i[requested]
    factory :received_reference_request,
            traits: %i[requested with_responses received]
  end
end
