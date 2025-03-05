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
    section_factory =
      AssessmentFactories::PersonalInformationSection.new(application_form:)

    checks = section_factory.checks
    failure_reasons = section_factory.failure_reasons

    AssessmentSection.new(
      key: "personal_information",
      checks:,
      failure_reasons:,
    )
  end

  def qualifications_section
    section_factory =
      AssessmentFactories::QualificationSection.new(application_form:)

    checks = section_factory.checks
    failure_reasons = section_factory.failure_reasons

    AssessmentSection.new(key: "qualifications", checks:, failure_reasons:)
  end

  def age_range_subjects_section
    section_factory =
      AssessmentFactories::AgeRangeSubjectsSection.new(application_form:)

    checks = section_factory.checks
    failure_reasons = section_factory.failure_reasons

    AssessmentSection.new(key: "age_range_subjects", checks:, failure_reasons:)
  end

  def english_language_proficiency_section
    section_factory =
      AssessmentFactories::EnglishLanguageProficiencySection.new(
        application_form:,
      )

    checks = section_factory.checks
    failure_reasons = section_factory.failure_reasons

    AssessmentSection.new(
      key: "english_language_proficiency",
      checks:,
      failure_reasons:,
    )
  end

  def work_history_section
    return nil unless application_form.needs_work_history

    section_factory =
      AssessmentFactories::WorkHistorySection.new(application_form:)

    checks = section_factory.checks
    failure_reasons = section_factory.failure_reasons

    AssessmentSection.new(key: "work_history", checks:, failure_reasons:)
  end

  def professional_standing_section
    unless application_form.needs_written_statement ||
             application_form.needs_registration_number
      return nil
    end

    section_factory =
      AssessmentFactories::ProfessionalStandingSection.new(application_form:)

    checks = section_factory.checks
    failure_reasons = section_factory.failure_reasons

    AssessmentSection.new(
      key: "professional_standing",
      checks:,
      failure_reasons:,
    )
  end

  def suitability_active?
    @suitability_active ||= FeatureFlags::FeatureFlag.active?(:suitability)
  end
end
