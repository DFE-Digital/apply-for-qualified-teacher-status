# frozen_string_literal: true

class AssessorInterface::ApplicationFormsIndexViewObject
  include ActionView::Helpers::FormOptionsHelper

  def initialize(params:)
    @params = params
  end

  def application_forms
    ALL_FILTERS.reduce(ApplicationForm.active) do |scope, filter|
      filter.apply(scope:, params:)
    end
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

  private

  ALL_FILTERS = [
    ::Filters::Name,
    ::Filters::Assessor,
    ::Filters::Country
  ].freeze

  attr_reader :params
end
