# frozen_string_literal: true

class AssessorInterface::ApplicationFormsIndexViewObject
  include ActionView::Helpers::FormOptionsHelper

  def initialize(params:)
    @params = params
  end

  def application_forms
    @application_forms ||=
      ::Filters::State.apply(
        scope: application_forms_without_state_filter,
        params:
      ).order(created_at: :desc)
  end

  def assessor_filter_options
    Staff.all
  end

  def assessor_filter_checked?(option)
    params[:assessor_ids]&.include?(option.id.to_s) || false
  end

  def country_filter_options
    options_for_select(
      Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST,
      params[:location]
    )
  end

  def name_filter_value
    params[:name]
  end

  def state_filter_options
    counts = application_forms_without_state_filter.group(:state).count
    states = %w[submitted awarded declined]

    states.map do |state|
      OpenStruct.new(
        id: state,
        label: "#{state.humanize} (#{counts.fetch(state, 0)})"
      )
    end
  end

  def state_filter_checked?(option)
    params[:states]&.include?(option.id) || false
  end

  private

  def application_forms_without_state_filter
    @application_forms_without_state_filter ||=
      begin
        filters = [::Filters::Name, ::Filters::Assessor, ::Filters::Country]
        filters.reduce(ApplicationForm.active) do |scope, filter|
          filter.apply(scope:, params:)
        end
      end
  end

  attr_reader :params
end
