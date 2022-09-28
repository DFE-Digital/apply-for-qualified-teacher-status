# == Schema Information
#
# Table name: assessment_sections
#
#  id                       :bigint           not null, primary key
#  checks                   :string           default([]), is an Array
#  failure_reasons          :string           default([]), is an Array
#  key                      :string           not null
#  passed                   :boolean
#  selected_failure_reasons :jsonb            not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  assessment_id            :bigint           not null
#
# Indexes
#
#  index_assessment_sections_on_assessment_id          (assessment_id)
#  index_assessment_sections_on_assessment_id_and_key  (assessment_id,key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
FactoryBot.define do
  factory :assessment_section do
    association :assessment

    trait :passed do
      passed { true }
    end

    trait :failed do
      passed { false }
      selected_failure_reasons { %w[failure_reason] }
    end

    trait :personal_information do
      key { "personal_information" }
      checks { %w[identification_document_present] }
      failure_reasons do
        %w[identification_document_expired identification_document_illegible]
      end
    end

    trait :qualifications do
      key { "qualifications" }
      checks do
        %w[
          identification_document_present
          qualifications_meet_level_6_or_equivalent
          teaching_qualifcations_completed_in_eligible_country
          qualified_in_mainstream_education
          has_teacher_qualification_certificate
          has_teacher_qualification_transcript
          has_university_degree_certificate
          has_university_degree_transcript
          has_additional_qualification_certificate
          has_additional_degree_transcript
        ]
      end
      failure_reasons do
        %w[
          teaching_qualifications_from_ineligible_country
          teaching_qualifications_not_at_required_level
          not_qualified_to_teach_mainstream
          teaching_certificate_illegible
          teaching_qualification_illegible
          degree_certificate_illegible
          degree_transcript_illegible
          application_and_qualification_names_do_not_match
          teaching_hours_not_fulfilled
          qualifications_dont_support_subjects
          qualifications_dont_match_those_entered
        ]
      end
    end

    trait :work_history do
      key { "work_history" }
      checks { %w[satisfactory_evidence_work_history] }
      failure_reasons { %w[satisfactory_evidence_work_history] }
    end

    trait :professional_standing do
      key { "professional_standing" }
      checks { %w[written_statement_present written_statement_recent] }
      failure_reasons do
        %w[written_statement_illegible written_statement_recent]
      end
    end
  end
end
