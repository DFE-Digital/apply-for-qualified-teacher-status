# frozen_string_literal: true

class AssessorInterface::ApplicationFormsIndexViewObject
  include ActionView::Helpers::FormOptionsHelper
  include Pagy::Backend
  include StatusHelper

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
    Staff.assessors.order(:name)
  end

  def country_filter_options
    options_for_select(
      Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST,
      filter_form.location,
    )
  end

  def state_filter_options
    counts = application_forms_without_state_filter.group(:state).count
    states = %w[
      submitted
      initial_assessment
      further_information_requested
      further_information_received
      awarded_pending_checks
      awarded
      declined
    ]

    states.map do |state|
      text = status_text(state, context: :assessor)
      OpenStruct.new(id: state, label: "#{text} (#{counts.fetch(state, 0)})")
    end
  end

  private

  def filter_params
    (session[:filter_params] || {}).with_indifferent_access
  end

  def application_forms_with_pagy
    @application_forms_with_pagy ||=
      pagy(
        ::Filters::State.apply(
          scope: application_forms_without_state_filter,
          params: filter_params,
        ).order(submitted_at: :asc),
      )
  end

  def application_forms_without_state_filter
    @application_forms_without_state_filter ||=
      begin
        filters = [
          ::Filters::Assessor,
          ::Filters::Country,
          ::Filters::Name,
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
