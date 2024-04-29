# == Schema Information
#
# Table name: assessment_sections
#
#  id              :bigint           not null, primary key
#  assessed_at     :datetime
#  checks          :string           default([]), is an Array
#  failure_reasons :string           default([]), is an Array
#  key             :string           not null
#  passed          :boolean
#  preliminary     :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  assessment_id   :bigint           not null
#
# Indexes
#
#  index_assessment_sections_on_assessment_id                  (assessment_id)
#  index_assessment_sections_on_assessment_id_preliminary_key  (assessment_id,preliminary,key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
FactoryBot.define do
  factory :assessment_section do
    assessment
    key { AssessmentSection.keys.keys.sample }
    preliminary { false }

    trait :preliminary do
      preliminary { true }
      key { "qualifications" }
    end

    trait :assessed do
      assessed_at { Time.zone.now }
    end

    trait :passed do
      assessed
      passed { true }
    end

    trait :failed do
      assessed
      passed { false }
      selected_failure_reasons do
        [build(:selected_failure_reason, :further_informationable)]
      end
    end

    trait :declines_assessment do
      assessed
      passed { false }
      selected_failure_reasons do
        [build(:selected_failure_reason, :declinable)]
      end
    end

    trait :declines_with_sanctions do
      assessed
      passed { false }
      selected_failure_reasons do
        [build(:selected_failure_reason, :with_sanctions)]
      end
    end

    trait :declines_with_already_qts do
      assessed
      passed { false }
      selected_failure_reasons do
        [build(:selected_failure_reason, :with_already_qts)]
      end
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
        if preliminary
          %w[
            qualifications_meet_level_6_or_equivalent
            teaching_qualifications_completed_in_eligible_country
          ]
        else
          %w[
            identification_document_present
            qualifications_meet_level_6_or_equivalent
            teaching_qualifications_completed_in_eligible_country
            qualified_in_mainstream_education
            has_teacher_qualification_certificate
            has_teacher_qualification_transcript
            has_university_degree_certificate
            has_university_degree_transcript
            has_additional_qualification_certificate
            has_additional_degree_transcript
          ]
        end
      end
      failure_reasons do
        if preliminary
          %w[
            teaching_qualifications_not_at_required_level
            teaching_qualification_subjects_criteria
          ]
        else
          %w[
            teaching_qualifications_from_ineligible_country
            teaching_qualifications_not_at_required_level
            not_qualified_to_teach_mainstream
            teaching_certificate_illegible
            teaching_transcript_illegible
            degree_certificate_illegible
            degree_transcript_illegible
            application_and_qualification_names_do_not_match
            teaching_hours_not_fulfilled
            qualifications_dont_match_subjects
            qualifications_dont_match_other_details
          ]
        end
      end
    end

    trait :age_range_subjects do
      key { "age_range_subjects" }
      checks do
        %w[qualified_in_mainstream_education age_range_subjects_matches]
      end
      failure_reasons { %w[not_qualified_to_teach_mainstream age_range] }
    end

    trait :english_language_proficiency do
      key { "english_language_proficiency" }
      checks { %w[] }
      failure_reasons { %w[] }
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
