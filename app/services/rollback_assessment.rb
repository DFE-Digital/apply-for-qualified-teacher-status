# frozen_string_literal: true

class RollbackAssessment
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      validate_state
      update_assessment
      update_application_form
      delete_draft_application_forms
    end
  end

  private

  attr_reader :assessment, :user

  def validate_state
    if has_submitted_another_application_form?
      raise InvalidState, "The teacher has submitted a subsequent application."
    end

    unless valid_assessment_state?
      raise InvalidState, "The assessment is not in a state to be rolled back."
    end
  end

  def has_submitted_another_application_form?
    teacher.application_form != application_form &&
      !teacher.application_form.draft?
  end

  def valid_assessment_state?
    assessment.award? || assessment.decline? ||
      (assessment.unknown? && application_form.declined?)
  end

  def update_assessment
    if previously_verified?
      assessment.verify!
    elsif previously_further_information_requested?
      assessment.request_further_information!
    else
      assessment.unknown!
    end
  end

  def previously_verified?
    assessment.reference_requests.exists?
  end

  def previously_further_information_requested?
    assessment.further_information_requests.exists?
  end

  delegate :application_form, to: :assessment
  delegate :teacher, to: :application_form

  def update_application_form
    if application_form.awarded?
      application_form.update!(awarded_at: nil)
    elsif application_form.declined?
      application_form.update!(declined_at: nil)
    end

    ApplicationFormStatusUpdater.call(application_form:, user:)
  end

  def delete_draft_application_forms
    ApplicationForm
      .draft
      .where(teacher:)
      .find_each do |application_form|
        DestroyApplicationForm.call(application_form:)
      end
  end

  class InvalidState < StandardError
  end
end
