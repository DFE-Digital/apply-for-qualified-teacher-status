# frozen_string_literal: true

# == Schema Information
#
# Table name: selected_failure_reasons
#
#  id                                   :bigint           not null, primary key
#  assessor_feedback                    :text
#  key                                  :string           not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  assessment_section_id                :bigint
#  prioritisation_work_history_check_id :bigint
#
# Indexes
#
#  index_as_failure_reason_assessment_section_id                 (assessment_section_id)
#  index_as_failure_reason_prioritisation_work_history_check_id  (prioritisation_work_history_check_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_section_id => assessment_sections.id)
#  fk_rails_...  (prioritisation_work_history_check_id => prioritisation_work_history_checks.id)
#

FactoryBot.define do
  factory :selected_failure_reason do
    assessment_section
    key { FailureReasons::ALL.sample }

    assessor_feedback do
      if FailureReasons.further_information?(key)
        "We need more information."
      else
        ""
      end
    end

    trait :further_informationable do
      key { FailureReasons::FURTHER_INFORMATIONABLE.sample }
    end

    trait :declinable do
      key { FailureReasons::DECLINABLE.sample }
    end

    trait :with_sanctions do
      key { "authorisation_to_teach" }
    end

    trait :with_already_qts do
      key { "applicant_already_qts" }
    end

    trait :with_suitability do
      key { "suitability" }
    end

    trait :with_suitability_previously_declined do
      key { "suitability_previously_declined" }
    end

    trait :with_fraud do
      key { "fraud" }
    end
  end
end
