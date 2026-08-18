# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementIndexViewObject
  include Pagy::Backend

  BREACH_STATUSES = %w[nearing breached].freeze
  COUNTRY_GROUPINGS = %w[uk_and_gibraltar eu efta rest_of_world].freeze

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

  def sla_working_day_tag_colour(application_form)
    if application_form.working_days_between_submitted_and_today.to_i >=
         breached_sla_working_day
      "red"
    else
      "yellow"
    end
  end

  def breach_statuses_options
    BREACH_STATUSES.map do |id|
      OpenStruct.new(id:, name: breach_status_label(id))
    end
  end

  def country_groupings_options
    COUNTRY_GROUPINGS.map do |id|
      OpenStruct.new(id:, name: country_grouping_label(id))
    end
  end

  def filter_form
    @filter_form ||= AssessorInterface::SLAFilterForm.new(filter_params)
  end

  private

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
      [
        ::Filters::SLA::BreachStatuses,
        ::Filters::SLA::CountryGroupings,
        ::Filters::Flags,
      ].reduce(
        sla_base_filter.apply(
          scope:
            ApplicationForm.includes(
              :assessment,
              :active_application_hold,
              region: :country,
            ),
          params: {
          },
        ),
      ) { |scope, filter| filter.apply(scope:, params: filter_params) }
  end

  def sla_base_filter
    if params[:sla] == "80"
      Filters::SLA::EightyDay
    elsif params[:sla] == "40"
      Filters::SLA::FortyDay
    else
      Filters::SLA::TenDay
    end
  end

  def breached_sla_working_day
    sla_base_filter::WORKING_DAYS_BREACHED_FROM
  end

  def filter_params
    (session[:sla_filter_params] || {}).merge(
      { sla: params[:sla] },
    ).with_indifferent_access
  end

  def breach_status_label(option)
    I18n.t(
      option,
      scope: %i[
        helpers
        label
        assessor_interface_sla_filter_form
        breach_statuses_options
      ],
      default: option.to_s.humanize,
    )
  end

  def country_grouping_label(option)
    I18n.t(
      option,
      scope: %i[
        helpers
        label
        assessor_interface_sla_filter_form
        country_grouping_options
      ],
      default: option.to_s.humanize,
    )
  end

  attr_reader :params, :session
end
