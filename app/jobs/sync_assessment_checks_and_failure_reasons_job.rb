# frozen_string_literal: true

class SyncAssessmentChecksAndFailureReasonsJob < ApplicationJob
  KEY_TO_FACTORY_CLASS_MAPPING = {
    personal_information: AssessmentFactories::PersonalInformationSection,
    qualifications: AssessmentFactories::QualificationSection,
    age_range_subjects: AssessmentFactories::AgeRangeSubjectsSection,
    english_language_proficiency:
      AssessmentFactories::EnglishLanguageProficiencySection,
    work_history: AssessmentFactories::WorkHistorySection,
    professional_standing: AssessmentFactories::ProfessionalStandingSection,
  }.freeze

  def perform(assessment)
    application_form = assessment.application_form

    unless %w[not_started pre_assessment].include?(application_form.stage)
      raise AssessmentAlreadyInProgress
    end

    assessment_sections = assessment.sections.not_preliminary

    assessment_sections.each do |assessment_section|
      section_factory =
        KEY_TO_FACTORY_CLASS_MAPPING[assessment_section.key.to_sym].new(
          application_form:,
        )

      checks = section_factory.checks
      failure_reasons = section_factory.failure_reasons

      assessment_section.update!(checks:, failure_reasons:)
    end
  end

  class AssessmentAlreadyInProgress < StandardError
  end
end
