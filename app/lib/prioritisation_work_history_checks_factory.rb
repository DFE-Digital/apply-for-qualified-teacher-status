# frozen_string_literal: true

class PrioritisationWorkHistoryChecksFactory
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    if application_form.includes_prioritisation_features?
      prioritisation_work_history_checks
    else
      []
    end
  end

  private

  attr_reader :application_form

  def prioritisation_work_history_checks
    valid_work_histories_for_prioritisation.map do |work_history|
      PrioritisationWorkHistoryCheck.new(
        work_history:,
        checks:,
        failure_reasons:,
      )
    end
  end

  def checks
    %w[
      prioritisation_work_history_role
      prioritisation_work_history_setting
      prioritisation_work_history_in_england
      prioritisation_work_history_reference_email
      prioritisation_work_history_reference_job
    ]
  end

  def failure_reasons
    %w[
      prioritisation_work_history_role
      prioritisation_work_history_setting
      prioritisation_work_history_in_england
      prioritisation_work_history_institution_not_found
      prioritisation_work_history_reference_email
      prioritisation_work_history_reference_job
    ]
  end

  def valid_work_histories_for_prioritisation
    work_histories_within_england.select do |work_history|
      work_history.still_employed ||
        work_history.end_date >= 1.year.ago.beginning_of_month
    end
  end

  def work_histories_within_england
    application_form.work_histories.within_england
  end
end
