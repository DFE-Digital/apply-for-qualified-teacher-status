# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementIndexViewObject
  include ActionView::Helpers::FormOptionsHelper
  include Pagy::Backend

  def initialize(params:)
    @params = params
  end

  def application_forms_pagy
    application_forms_with_pagy.first
  end

  def application_forms_records
    application_forms_with_pagy.last
  end

  def breached_sla_for_starting_prioritisation_checks_count
    application_forms_with_prioritisation_checks_not_started.where(
      "working_days_between_submitted_and_today > ?",
      WORKING_DAYS_TO_START_PRIORITISATION_CHECKS,
    ).count
  end

  def nearing_sla_for_starting_prioritisation_checks_count
    application_forms_with_prioritisation_checks_not_started.where(
      working_days_between_submitted_and_today:
        WORKING_DAYS_NEARING_START_PRIORITISATION_CHECKS_DEADLINE..WORKING_DAYS_TO_START_PRIORITISATION_CHECKS,
    ).count
  end

  def breached_sla_for_completing_prioritised_applications_count
    application_forms_prioritised_but_assessment_not_completed.where(
      "working_days_between_submitted_and_today > ?",
      WORKING_DAYS_TO_FINISH_ASSESSMENT_FOR_PRIORITISED,
    ).count
  end

  def nearing_sla_for_completing_prioritised_applications_count
    application_forms_prioritised_but_assessment_not_completed.where(
      working_days_between_submitted_and_today:
        WORKING_DAYS_NEARING_FINISH_ASSESSMENT_FOR_PRIORITISED_DEADLINE..WORKING_DAYS_TO_FINISH_ASSESSMENT_FOR_PRIORITISED,
    ).count
  end

  def sla_start_prioritisation_checks_tag_colour(application_form)
    return if application_form.assessment.nil?

    if application_form.assessment.started_at.present? ||
         application_form.assessment.prioritisation_work_history_checks.empty?
      return
    end

    if application_form.working_days_between_submitted_and_today.to_i >
         WORKING_DAYS_TO_START_PRIORITISATION_CHECKS
      "red"
    elsif application_form.working_days_between_submitted_and_today.to_i >=
          WORKING_DAYS_NEARING_START_PRIORITISATION_CHECKS_DEADLINE
      "yellow"
    else
      "green"
    end
  end

  def sla_completed_prioritised_tag_colour(application_form)
    return if application_form.assessment.nil?

    if !application_form.assessment.prioritised? ||
         application_form.assessment.verification_started_at.present?
      return
    end

    if application_form.working_days_between_submitted_and_today.to_i >
         WORKING_DAYS_TO_FINISH_ASSESSMENT_FOR_PRIORITISED
      "red"
    elsif application_form.working_days_between_submitted_and_today.to_i >=
          WORKING_DAYS_NEARING_FINISH_ASSESSMENT_FOR_PRIORITISED_DEADLINE
      "yellow"
    else
      "green"
    end
  end

  private

  WORKING_DAYS_TO_START_PRIORITISATION_CHECKS = 10
  WORKING_DAYS_NEARING_START_PRIORITISATION_CHECKS_DEADLINE = 8

  WORKING_DAYS_TO_FINISH_ASSESSMENT_FOR_PRIORITISED = 40
  WORKING_DAYS_NEARING_FINISH_ASSESSMENT_FOR_PRIORITISED_DEADLINE = 35

  def application_forms_with_pagy
    @application_forms_with_pagy ||=
      pagy(
        application_forms_with_filter.order(
          working_days_between_submitted_and_today: :desc,
        ),
      )
  end

  def application_forms_with_filter
    @application_forms_with_filter ||=
      if params[:tab] == "40"
        application_forms_prioritised_but_assessment_not_completed
      else
        application_forms_with_prioritisation_checks_not_started
      end
  end

  def application_forms_with_prioritisation_checks_not_started
    ApplicationForm
      .joins(assessment: :prioritisation_work_history_checks)
      .where(assessment: { started_at: nil })
      .distinct
  end

  def application_forms_prioritised_but_assessment_not_completed
    ApplicationForm
      .joins(:assessment)
      .where(assessment: { verification_started_at: nil, prioritised: true })
      .distinct
  end

  attr_reader :params
end
