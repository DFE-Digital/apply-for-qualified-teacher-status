# == Schema Information
#
# Table name: assessment_section_failure_reasons
#
#  id                    :bigint           not null, primary key
#  assessor_feedback     :text
#  key                   :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_section_id :bigint           not null
#
# Indexes
#
#  index_as_failure_reason_assessment_section_id  (assessment_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_section_id => assessment_sections.id)
#
FactoryBot.define do
  factory :assessment_section_failure_reason do
    association :assessment_section
    key { FailureReasons::ALL.sample }

    trait :fi_requestable do
      key { FailureReasons::FURTHER_INFORMATIONABLE.sample }
      assessor_feedback { "We need more things please" }
    end

    trait :declinable do
      key { FailureReasons::DECLINABLE.sample }
    end
  end
end
