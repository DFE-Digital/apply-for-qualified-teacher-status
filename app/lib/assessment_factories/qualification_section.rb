# frozen_string_literal: true

module AssessmentFactories
  class QualificationSection
    def initialize(application_form:)
      @application_form = application_form
    end

    def checks
      [
        "qualifications_meet_level_6_or_equivalent",
        "qualified_in_mainstream_education",
        (
          if application_form.subject_limited
            "qualified_to_teach_children_11_to_16"
          end
        ),
        (
          if application_form.subject_limited
            "teaching_qualification_subjects_criteria"
          end
        ),
        "has_teacher_qualification_certificate",
        "has_teacher_qualification_transcript",
        "has_university_degree_certificate",
        "has_university_degree_transcript",
        "has_additional_qualification_certificate",
        "has_additional_degree_transcript",
        "teaching_qualification_pedagogy",
        "teaching_qualification_1_year",
      ].compact
    end

    def failure_reasons
      reasons = [
        FailureReasons::APPLICATION_AND_QUALIFICATION_NAMES_DO_NOT_MATCH,
        FailureReasons::TEACHING_QUALIFICATIONS_FROM_INELIGIBLE_COUNTRY,
        FailureReasons::TEACHING_QUALIFICATIONS_NOT_AT_REQUIRED_LEVEL,
        FailureReasons::TEACHING_HOURS_NOT_FULFILLED,
        FailureReasons::TEACHING_QUALIFICATION_PEDAGOGY,
        FailureReasons::TEACHING_QUALIFICATION_1_YEAR,
        (
          if application_form.english_language_qualification_exempt
            FailureReasons::EL_EXEMPTION_BY_QUALIFICATION_DOCUMENTS_UNCONFIRMED
          end
        ),
        FailureReasons::NOT_QUALIFIED_TO_TEACH_MAINSTREAM,
        FailureReasons::QUALIFICATIONS_DONT_MATCH_OTHER_DETAILS,
        (
          if application_form.subject_limited
            FailureReasons::QUALIFIED_TO_TEACH_CHILDREN_11_TO_16
          end
        ),
        (
          if application_form.subject_limited
            FailureReasons::TEACHING_QUALIFICATION_SUBJECTS_CRITERIA
          end
        ),
        FailureReasons::TEACHING_CERTIFICATE_ILLEGIBLE,
        FailureReasons::TEACHING_TRANSCRIPT_ILLEGIBLE,
        FailureReasons::DEGREE_CERTIFICATE_ILLEGIBLE,
        FailureReasons::DEGREE_TRANSCRIPT_ILLEGIBLE,
        FailureReasons::ADDITIONAL_DEGREE_CERTIFICATE_ILLEGIBLE,
        FailureReasons::ADDITIONAL_DEGREE_TRANSCRIPT_ILLEGIBLE,
        FailureReasons::SPECIAL_EDUCATION_ONLY,
      ].compact

      if suitability_active?
        reasons += [
          FailureReasons::SUITABILITY,
          FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
          FailureReasons::FRAUD,
        ]
      end

      reasons
    end

    private

    attr_reader :application_form

    def suitability_active?
      @suitability_active ||= FeatureFlags::FeatureFlag.active?(:suitability)
    end
  end
end
