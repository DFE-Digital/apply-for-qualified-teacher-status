# frozen_string_literal: true

class AssessorInterface::ApplicationFormsIndexViewObject
  include ActionView::Helpers::FormOptionsHelper
  include Pagy::Backend

  def initialize(params:, session:)
    @params = params
    @session = session
  end

  def application_forms_pagy
    application_forms_with_pagy.first
  end

  def application_forms_records
    application_forms_with_pagy.last
  end

  def filter_form
    @filter_form ||= AssessorInterface::FilterForm.new(filter_params)
  end

  def assessor_filter_options
    Staff.assessors.order(:name) +
      [OpenStruct.new(id: "null", name: "Not assigned")]
  end

  def country_filter_options
    options_for_select(
      Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST,
      filter_form.location,
    )
  end

  def status_filter_options
    counts = application_forms_without_status_filter.group(:status).count
    statuses = %w[
      preliminary_check
      submitted
      assessment_in_progress
      waiting_on
      received
      overdue
      awarded_pending_checks
      awarded
      declined
      potential_duplicate_in_dqt
      withdrawn
    ]

    statuses.map do |status|
      text = I18n.t(status, scope: %i[components status_tag])
      OpenStruct.new(id: status, label: "#{text} (#{counts.fetch(status, 0)})")
    end
  end

  private

  def filter_params
    (session[:filter_params] || {}).with_indifferent_access
  end

  def application_forms_with_pagy
    @application_forms_with_pagy ||=
      pagy(
        ::Filters::Status.apply(
          scope: application_forms_without_status_filter,
          params: filter_params,
        ).order(submitted_at: :asc),
      )
  end

  def application_forms_without_status_filter
    @application_forms_without_status_filter ||=
      begin
        filters = [
          ::Filters::Assessor,
          ::Filters::Country,
          ::Filters::Name,
          ::Filters::Email,
          ::Filters::Reference,
          ::Filters::SubmittedAt,
        ]
        filters.reduce(
          ApplicationForm.includes(region: :country).active,
        ) { |scope, filter| filter.apply(scope:, params: filter_params) }
      end
  end

  attr_reader :params, :session
end
