# == Schema Information
#
# Table name: assessments
#
#  id                                        :bigint           not null, primary key
#  age_range_max                             :integer
#  age_range_min                             :integer
#  age_range_note                            :text             default(""), not null
#  induction_required                        :boolean
#  qualifications_assessor_note              :text             default(""), not null
#  recommendation                            :string           default("unknown"), not null
#  recommendation_assessor_note              :text             default(""), not null
#  recommended_at                            :datetime
#  references_verified                       :boolean
#  scotland_full_registration                :boolean
#  started_at                                :datetime
#  subjects                                  :text             default([]), not null, is an Array
#  subjects_note                             :text             default(""), not null
#  unsigned_consent_document_generated       :boolean          default(FALSE), not null
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

    induction_required do
      application_form.reduced_evidence_accepted ? false : nil
    end

    trait :started do
      started_at { Time.zone.now }
      after(:create) do |assessment, _evaluator|
        create(:assessment_section, :passed, assessment:)
      end
    end

    trait :award do
      recommendation { "award" }
      recommended_at { Time.zone.now }
    end

    trait :decline do
      recommendation { "decline" }
      recommended_at { Time.zone.now }
    end

    trait :review do
      recommendation { "review" }
      recommended_at { Time.zone.now }
    end

    trait :verify do
      recommendation { "verify" }
      recommended_at { Time.zone.now }
    end

    trait :with_preliminary_qualifications_section do
      after(:create) do |assessment, _evaulator|
        create(:assessment_section, :preliminary, :qualifications, assessment:)
      end
    end

    trait :with_consent_requests do
      after(:create) do |assessment, _evaluator|
        assessment.application_form.qualifications.each do |qualification|
          create(:consent_request, assessment:, qualification:)
        end
      end
    end

    trait :with_further_information_request do
      after(:create) do |assessment, _evaluator|
        create(:requested_further_information_request, :with_items, assessment:)
      end
    end

    trait :with_professional_standing_request do
      after(:create) do |assessment, _evaluator|
        create(:professional_standing_request, assessment:)
      end
    end

    trait :with_reference_requests do
      after(:create) do |assessment, _evaluator|
        assessment.application_form.work_histories.each do |work_history|
          create(:reference_request, assessment:, work_history:)
        end
      end
    end

    trait :with_qualification_requests do
      qualifications_assessor_note { Faker::Lorem.sentence }

      after(:create) do |assessment, _evaluator|
        assessment.application_form.qualifications.each do |qualification|
          create(:qualification_request, assessment:, qualification:)
        end
      end
    end
  end
end
