# frozen_string_literal: true

class AssessmentFactory
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    sections =
      [
        personal_information_section,
        qualifications_section,
        age_range_subjects_section,
        english_language_proficiency_section,
        work_history_section,
        professional_standing_section,
      ].compact + PreliminaryAssessmentSectionsFactory.call(application_form:)

    Assessment.create!(
      application_form:,
      sections:,
      age_range_min: application_form.age_range_min,
      age_range_max: application_form.age_range_max,
    )
  end

  private

  attr_reader :application_form

  def personal_information_section
    checks = [
      :identification_document_present,
      (:name_change_document_present if application_form.has_alternative_name),
      :duplicate_application,
      :applicant_already_qts,
      :applicant_already_dqt,
    ].compact

    failure_reasons = [
      FailureReasons::IDENTIFICATION_DOCUMENT_EXPIRED,
      FailureReasons::IDENTIFICATION_DOCUMENT_ILLEGIBLE,
      FailureReasons::IDENTIFICATION_DOCUMENT_MISMATCH,
      (
        if application_form.has_alternative_name
          FailureReasons::NAME_CHANGE_DOCUMENT_ILLEGIBLE
        end
      ),
      (
        if application_form.english_language_citizenship_exempt
          FailureReasons::EL_EXEMPTION_BY_CITIZENSHIP_ID_UNCONFIRMED
        end
      ),
      FailureReasons::DUPLICATE_APPLICATION,
      FailureReasons::APPLICANT_ALREADY_QTS,
      FailureReasons::APPLICANT_ALREADY_DQT,
      FailureReasons::SUITABILITY,
      FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
      FailureReasons::FRAUD,
    ].compact

    AssessmentSection.new(
      key: "personal_information",
      checks:,
      failure_reasons:,
    )
  end

  def qualifications_section
    checks = [
      "qualifications_meet_level_6_or_equivalent",
      "teaching_qualifications_completed_in_eligible_country",
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

    failure_reasons = [
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
      FailureReasons::QUALIFICATIONS_DONT_MATCH_SUBJECTS,
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
      FailureReasons::SUITABILITY,
      FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
      FailureReasons::SPECIAL_EDUCATION_ONLY,
      FailureReasons::FRAUD,
    ].compact

    AssessmentSection.new(key: "qualifications", checks:, failure_reasons:)
  end

  def age_range_subjects_section
    checks = [
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
      "age_range_subjects_matches",
    ].compact

    failure_reasons = [
      FailureReasons::NOT_QUALIFIED_TO_TEACH_MAINSTREAM,
      FailureReasons::AGE_RANGE,
      FailureReasons::SUITABILITY,
      FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
      FailureReasons::FRAUD,
    ]

    AssessmentSection.new(key: "age_range_subjects", checks:, failure_reasons:)
  end

  def english_language_proficiency_section
    checks =
      if application_form.english_language_exempt?
        []
      elsif application_form.english_language_proof_method_medium_of_instruction?
        %i[english_language_valid_moi]
      else
        %i[english_language_valid_provider]
      end

    failure_reasons =
      if application_form.english_language_exempt?
        []
      elsif application_form.english_language_proof_method_medium_of_instruction?
        [
          FailureReasons::EL_MOI_NOT_TAUGHT_IN_ENGLISH,
          FailureReasons::EL_MOI_INVALID_FORMAT,
        ]
      else
        [
          FailureReasons::EL_QUALIFICATION_INVALID,
          (
            if application_form.english_language_provider_other
              FailureReasons::EL_PROFICIENCY_DOCUMENT_ILLEGIBLE
            else
              FailureReasons::EL_UNVERIFIABLE_REFERENCE_NUMBER
            end
          ),
          FailureReasons::EL_GRADE_BELOW_B2,
          FailureReasons::EL_SELT_EXPIRED,
        ]
      end

    failure_reasons += [
      FailureReasons::SUITABILITY,
      FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
      FailureReasons::FRAUD,
    ]

    AssessmentSection.new(
      key: "english_language_proficiency",
      checks:,
      failure_reasons:,
    )
  end

  def work_history_section
    return nil unless application_form.needs_work_history

    checks = %i[verify_school_details work_history_references]

    failure_reasons = [
      FailureReasons::WORK_HISTORY_BREAK,
      FailureReasons::SCHOOL_DETAILS_CANNOT_BE_VERIFIED,
      FailureReasons::UNRECOGNISED_REFERENCES,
      FailureReasons::WORK_HISTORY_DURATION,
      FailureReasons::SUITABILITY,
      FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
      FailureReasons::FRAUD,
    ]

    AssessmentSection.new(key: "work_history", checks:, failure_reasons:)
  end

  def professional_standing_section
    unless application_form.needs_written_statement ||
             application_form.needs_registration_number
      return nil
    end

    has_registration_number = application_form.needs_registration_number
    written_statement_required =
      application_form.needs_written_statement &&
        !application_form.written_statement_optional
    written_statement_induction =
      application_form.needs_written_statement &&
        !application_form.needs_work_history

    checks = [
      (:registration_number if has_registration_number),
      (:written_statement_present if written_statement_required),
      (:written_statement_recent if written_statement_required),
      (:written_statement_induction if written_statement_induction),
      (:written_statement_completion_date if written_statement_induction),
      (:written_statement_registration_number if written_statement_induction),
      (:written_statement_school_name if written_statement_induction),
      (:written_statement_signature if written_statement_induction),
      :authorisation_to_teach,
      :teaching_qualification,
      :confirm_age_range_subjects,
      :qualified_to_teach,
      :full_professional_status,
    ].compact

    failure_reasons = [
      (FailureReasons::REGISTRATION_NUMBER if has_registration_number),
      (
        if has_registration_number
          FailureReasons::REGISTRATION_NUMBER_ALTERNATIVE
        end
      ),
      (
        if application_form.needs_written_statement
          FailureReasons::WRITTEN_STATEMENT_ILLEGIBLE
        end
      ),
      (FailureReasons::WRITTEN_STATEMENT_RECENT if written_statement_required),
      (
        if written_statement_induction
          FailureReasons::WRITTEN_STATEMENT_INFORMATION
        end
      ),
      FailureReasons::AUTHORISATION_TO_TEACH,
      FailureReasons::TEACHING_QUALIFICATION,
      FailureReasons::CONFIRM_AGE_RANGE_SUBJECTS,
      FailureReasons::QUALIFIED_TO_TEACH,
      FailureReasons::FULL_PROFESSIONAL_STATUS,
      FailureReasons::SUITABILITY,
      FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
      FailureReasons::FRAUD,
    ].compact

    AssessmentSection.new(
      key: "professional_standing",
      checks:,
      failure_reasons:,
    )
  end
end
