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

  def action_required_by_filter_options
    ACTION_REQUIRED_BY_OPTIONS.map do |name|
      action_required_by_filter_entry(name)
    end
  end

  def status_filter_options
    STATUS_FILTER_OPTIONS.each_with_object({}) do |(status, substatuses), memo|
      memo[status_filter_entry(status)] = substatuses.map do |sub_status|
        status_filter_entry(status, sub_status)
      end
    end
  end

  private

  ACTION_REQUIRED_BY_OPTIONS = %w[admin assessor external].freeze

  STATUS_FILTER_OPTIONS = {
    preliminary_check: [],
    submitted: [],
    assessment_in_progress: [],
    waiting_on: %i[
      further_information
      professional_standing
      qualification
      reference
    ],
    received: %i[
      further_information
      professional_standing
      qualification
      reference
    ],
    overdue: [],
    awarded_pending_checks: [],
    awarded: [],
    declined: [],
    potential_duplicate_in_dqt: [],
    withdrawn: [],
  }.freeze

  def filter_params
    (session[:filter_params] || {}).with_indifferent_access
  end

  def application_forms_without_action_required_by_filter
    @application_forms_without_action_required_by_filter ||=
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

  def application_forms_without_status_filter
    @application_forms_without_status_filter ||=
      ::Filters::ActionRequiredBy.apply(
        scope: application_forms_without_action_required_by_filter,
        params: filter_params,
      )
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

  def action_required_by_filter_counts
    @action_required_by_filter_counts ||=
      application_forms_without_action_required_by_filter.group(
        :action_required_by,
      ).count
  end

  def action_required_by_filter_entry(name)
    OpenStruct.new(
      id: name,
      label:
        "#{name.humanize} (#{action_required_by_filter_counts.fetch(name, 0)})",
    )
  end

  def status_filter_counts
    @status_filter_counts ||=
      begin
        all_options =
          STATUS_FILTER_OPTIONS.each_with_object(
            {},
          ) do |(status, substatuses), memo|
            memo[status.to_s] = nil

            substatuses.each do |substatus|
              memo["#{status}_#{substatus}"] = status.to_s
            end
          end

        table = ApplicationForm.arel_table

        counts =
          all_options.filter_map do |status, parent_status|
            if parent_status.present?
              Arel.star.count.filter(
                table[:status].eq(parent_status).and(table[status].eq(true)),
              )
            else
              Arel.star.count.filter(table[:status].eq(status))
            end
          end

        results = application_forms_without_status_filter.pick(*counts)

        Hash[all_options.keys.zip(results)]
      end
  end

  def status_filter_entry(*status_path)
    name = status_path.join("_")

    readable_name =
      I18n.t(
        status_path.last,
        scope: %i[components status_tag],
        default: status_path.last.to_s.humanize,
      )

    OpenStruct.new(
      id: name,
      label: "#{readable_name} (#{status_filter_counts.fetch(name, 0)})",
    )
  end

  attr_reader :params, :session
end
