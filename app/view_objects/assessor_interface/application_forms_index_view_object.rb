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
    ApplicationForm
      .joins(:assessor)
      .pluck(Arel.sql("DISTINCT ON(assessor_id) assessor_id"), "staff.name")
      .sort_by { |_id, name| name }
      .map { |id, name| OpenStruct.new(id:, name:) } +
      [OpenStruct.new(id: "null", name: "Not assigned")]
  end

  def country_filter_options
    options_for_select(
      Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST,
      filter_form.location,
    )
  end

  def action_required_by_filter_options
    ACTION_REQUIRED_BY_OPTIONS.map do |name|
      action_required_by_filter_entry(name)
    end
  end

  def stage_filter_options
    STAGE_FILTER_OPTIONS.map { |name| stage_filter_entry(name) }
  end

  private

  ACTION_REQUIRED_BY_OPTIONS = %w[admin assessor external].freeze

  STAGE_FILTER_OPTIONS = %w[
    pre_assessment
    not_started
    assessment
    verification
    review
    completed
  ].freeze

  def filter_params
    (session[:filter_params] || {}).with_indifferent_access
  end

  def application_forms_without_counted_filters
    @application_forms_without_counted_filters ||=
      begin
        filters = [
          ::Filters::Assessor,
          ::Filters::Country,
          ::Filters::Name,
          ::Filters::Email,
          ::Filters::Reference,
          ::Filters::SubmittedAt,
          ::Filters::ShowAllApplications,
        ]
        filters.reduce(
          ApplicationForm.includes(region: :country).submitted,
        ) { |scope, filter| filter.apply(scope:, params: filter_params) }
      end
  end

  def application_forms_with_pagy
    @application_forms_with_pagy ||=
      pagy(
        ::Filters::Stage.apply(
          scope:
            ::Filters::ActionRequiredBy.apply(
              scope: application_forms_without_counted_filters,
              params: filter_params,
            ),
          params: filter_params,
        ).order(submitted_at: :asc),
      )
  end

  def action_required_by_filter_counts
    @action_required_by_filter_counts ||=
      ::Filters::Stage
        .apply(
          scope: application_forms_without_counted_filters,
          params: filter_params,
        )
        .group(:action_required_by)
        .count
  end

  def action_required_by_filter_entry(name)
    OpenStruct.new(
      id: name,
      label:
        "#{name.humanize} (#{action_required_by_filter_counts.fetch(name, 0)})",
    )
  end

  def stage_filter_counts
    @stage_filter_counts ||=
      ::Filters::ActionRequiredBy
        .apply(
          scope: application_forms_without_counted_filters,
          params: filter_params,
        )
        .group(:stage)
        .count
  end

  def stage_filter_entry(name)
    readable_name =
      I18n.t(
        name,
        scope: %i[components status_tag],
        default: name.to_s.humanize,
      )

    OpenStruct.new(
      id: name,
      label: "#{readable_name} (#{stage_filter_counts.fetch(name, 0)})",
    )
  end

  attr_reader :params, :session
end
