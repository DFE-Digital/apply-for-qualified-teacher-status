# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementIndexViewObject
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

  def sla_working_day_tag_colour(application_form)
    if application_form.working_days_between_submitted_and_today.to_i >=
         breached_sla_working_day
      "red"
    else
      "yellow"
    end
  end

  def breach_statuses_options
    [
      OpenStruct.new(id: "nearing", name: "Nearing"),
      OpenStruct.new(id: "breached", name: "Breached"),
    ]
  end

  def country_groupings_options
    [
      OpenStruct.new(id: "uk_and_gibraltar", name: "UK & Gibraltar"),
      OpenStruct.new(id: "eu", name: "EU"),
      OpenStruct.new(id: "efta", name: "EFTA"),
      OpenStruct.new(id: "rest_of_world", name: "Rest of the world"),
    ]
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
      Filters::SLA::FourtyDay
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

  attr_reader :params, :session
end
