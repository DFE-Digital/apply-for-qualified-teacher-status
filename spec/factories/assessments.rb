# == Schema Information
#
# Table name: assessments
#
#  id                                        :bigint           not null, primary key
#  age_range_max                             :integer
#  age_range_min                             :integer
#  age_range_note                            :text             default(""), not null
#  induction_required                        :boolean
#  recommendation                            :string           default("unknown"), not null
#  recommended_at                            :datetime
#  started_at                                :datetime
#  subjects                                  :text             default([]), not null, is an Array
#  subjects_note                             :text             default(""), not null
#  working_days_since_started                :integer
#  working_days_started_to_recommendation    :integer
#  working_days_submission_to_recommendation :integer
#  working_days_submission_to_started        :integer
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  application_form_id                       :bigint           not null
#
# Indexes
#
#  index_assessments_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :assessment do
    association :application_form, :submitted

    trait :award do
      recommendation { "award" }
      recommended_at { Time.zone.now }
    end

    trait :with_further_information_request do
      after(:create) do |assessment, _evaluator|
        create(
          :further_information_request,
          :requested,
          :with_items,
          assessment:,
        )
      end
    end

    trait :with_reference_request do
      after(:create) do |assessment, _evaluator|
        create(
          :reference_request,
          :requested,
          assessment:,
          work_history: assessment.application_form.work_histories.first,
        )
      end
    end
  end
end
