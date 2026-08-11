# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementIndexViewObject
  include ActionView::Helpers::FormOptionsHelper
  include Pagy::Backend

  WORKING_DAYS_FOR_EIGHTY_DAY = 80
  WORKING_DAYS_FOR_FOURTY_DAY = 40
  WORKING_DAYS_FOR_TEN_DAY = 10

  def initialize(params:)
    @params = params
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
      sla_base_filter.apply(scope: ApplicationForm, params: params)
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
    if params[:sla] == "80"
      WORKING_DAYS_FOR_EIGHTY_DAY
    elsif params[:sla] == "40"
      WORKING_DAYS_FOR_FOURTY_DAY
    else
      WORKING_DAYS_FOR_TEN_DAY
    end
  end

  attr_reader :params
end
