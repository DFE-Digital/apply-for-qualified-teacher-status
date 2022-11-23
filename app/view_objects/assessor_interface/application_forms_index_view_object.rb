# frozen_string_literal: true

class AssessorInterface::ApplicationFormsIndexViewObject
  include ActionView::Helpers::FormOptionsHelper
  include Pagy::Backend

  def initialize(params:)
    @params = remove_cleared_autocomplete_values(params)
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
      key_with_context = "application_form.status.#{state}.assessor"
      key_without_context = "application_form.status.#{state}"
      text = I18n.t(key_with_context, default: I18n.t(key_without_context))
      OpenStruct.new(id: state, label: "#{text} (#{counts.fetch(state, 0)})")
    end
  end

  def permitted_params
    params.permit(
      :location_autocomplete,
      :page,
      assessor_interface_filter_form: [
        :location,
        :name,
        :reference,
        :submitted_at_before,
        :submitted_at_after,
        { assessor_ids: [], states: [] },
      ],
    )
  end

  private

  def filter_params
    permitted_params[:assessor_interface_filter_form] || {}
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

  def remove_cleared_autocomplete_values(params)
    if params.include?(:location_autocomplete) &&
         params[:location_autocomplete].blank?
      params[:assessor_interface_filter_form]&.delete(:location)
    end

    params
  end

  attr_reader :params
end
