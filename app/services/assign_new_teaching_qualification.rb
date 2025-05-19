# frozen_string_literal: true

class AssignNewTeachingQualification
  include ServicePattern

  def initialize(
    current_teaching_qualification:,
    new_teaching_qualification:,
    user:
  )
    @current_teaching_qualification = current_teaching_qualification
    @new_teaching_qualification = new_teaching_qualification
    @user = user
  end

  def call
    if !current_teaching_qualification.is_teaching? ||
         new_teaching_qualification.is_teaching?
      raise AlreadyReassigned,
            "Teaching qualification has already changed, please review and try again"
    end

    unless application_form.not_started_stage? ||
             application_form.assessment_stage? ||
             application_form.review_stage?
      raise InvalidState,
            "Teaching qualification can only be update while the application is in assessment or review stage"
    end

    if new_teaching_qualification.institution_country_code !=
         application_form.country.code
      raise InvalidInstitutionCountry
    end

    ActiveRecord::Base.transaction do
      new_teaching_qualification.update!(
        created_at: current_teaching_qualification.created_at - 1.hour,
      )

      unless has_enough_work_history_for_submission?
        raise InvalidWorkHistoryDuration
      end

      UpdateAssessmentInductionRequired.call(assessment:) if application_form.review_stage?

      create_timeline_event(
        :teaching_qualification,
        current_teaching_qualification.title,
        new_teaching_qualification.title,
      )
    end
  end

  private

  attr_reader :current_teaching_qualification,
              :new_teaching_qualification,
              :user

  delegate :application_form, to: :new_teaching_qualification
  delegate :assessment, to: :application_form

  def create_timeline_event(column_name, old_value, new_value)
    CreateTimelineEvent.call(
      "information_changed",
      application_form:,
      user:,
      column_name:,
      old_value:,
      new_value:,
    )
  end

  def has_enough_work_history_for_submission?
    WorkHistoryDuration.for_application_form(
      application_form.reload,
    ).enough_for_submission?
  end

  class InvalidState < StandardError
  end

  class AlreadyReassigned < StandardError
  end

  class InvalidInstitutionCountry < StandardError
  end

  class InvalidWorkHistoryDuration < StandardError
  end
end
