# frozen_string_literal: true

class PreliminaryAssessmentSectionsFactory
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_form.requires_preliminary_check ? [qualifications] : []
  end

  private

  attr_reader :application_form

  def qualifications
    AssessmentSection.new(
      preliminary: true,
      key: "qualifications",
      checks: qualifications_checks,
      failure_reasons: qualifications_failure_reasons,
    )
  end

  def qualifications_checks
    if application_form.subject_limited
      %w[
        qualifications_meet_level_6_or_equivalent
        teaching_qualification_subjects_criteria
      ]
    else
      []
    end
  end

  def qualifications_failure_reasons
    [
      FailureReasons::TEACHING_QUALIFICATIONS_NOT_AT_REQUIRED_LEVEL,
      if application_form.subject_limited
        FailureReasons::TEACHING_QUALIFICATION_SUBJECTS_CRITERIA
      end,
    ].compact
  end
end
