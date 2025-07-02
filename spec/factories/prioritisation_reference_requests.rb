# frozen_string_literal: true

# == Schema Information
#
# Table name: prioritisation_reference_requests
#
#  id                                   :bigint           not null, primary key
#  confirm_applicant_comment            :text             default(""), not null
#  confirm_applicant_response           :boolean
#  contact_comment                      :text             default(""), not null
#  contact_response                     :boolean
#  expired_at                           :datetime
#  received_at                          :datetime
#  requested_at                         :datetime
#  review_note                          :text             default(""), not null
#  review_passed                        :boolean
#  reviewed_at                          :datetime
#  slug                                 :string           not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  assessment_id                        :bigint           not null
#  prioritisation_work_history_check_id :bigint           not null
#  work_history_id                      :bigint           not null
#
# Indexes
#
#  idx_on_prioritisation_work_history_check_id_179105c28e      (prioritisation_work_history_check_id)
#  index_prioritisation_reference_requests_on_assessment_id    (assessment_id)
#  index_prioritisation_reference_requests_on_slug             (slug) UNIQUE
#  index_prioritisation_reference_requests_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (prioritisation_work_history_check_id => prioritisation_work_history_checks.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
FactoryBot.define do
  factory :prioritisation_reference_request do
    assessment

    slug { Faker::Internet.unique.slug }

    work_history do
      create(
        :work_history,
        :completed,
        application_form: assessment.application_form,
      )
    end

    prioritisation_work_history_check do
      create(:prioritisation_work_history_check, assessment: assessment)
    end

    trait :with_responses do
      contact_response { Faker::Boolean.boolean }
      contact_comment { contact_response ? "" : Faker::Lorem.sentence }

      confirm_applicant_response { Faker::Boolean.boolean }
      confirm_applicant_comment do
        confirm_applicant_response ? Faker::Lorem.sentence : ""
      end
    end

    factory :requested_prioritisation_reference_request, traits: %i[requested]
    factory :received_prioritisation_reference_request,
            traits: %i[requested with_responses received]
  end
end
