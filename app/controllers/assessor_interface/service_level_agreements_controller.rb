# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementsController < AssessorInterface::BaseController
  before_action { authorize %i[assessor_interface service_level_agreement] }

  def index
    @view_object =
      AssessorInterface::ServiceLevelAgreementIndexViewObject.new(
        params:,
        session:,
      )

    render layout: "full_from_desktop"
  end

  def apply_filters
    session[:sla_filter_params] = extract_filter_params(params)

    redirect_to assessor_interface_service_level_agreements_path(
                  sla: session[:sla_filter_params][:sla],
                )
  end

  def clear_filters
    session[:sla_filter_params] = {}

    redirect_to assessor_interface_service_level_agreements_path(
                  sla: session[:sla_filter_params][:sla],
                )
  end

  def totals
  end

  private

  def extract_filter_params(params)
    params[:assessor_interface_sla_filter_form].permit!.to_h
  end
end
