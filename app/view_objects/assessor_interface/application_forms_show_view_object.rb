# frozen_string_literal: true

class AssessorInterface::ApplicationFormsShowViewObject
  def initialize(params:)
    @params = params
  end

  def application_form
    @application_form ||= ApplicationForm.find(params[:id])
  end

  def back_link_path
    Rails
      .application
      .routes
      .url_helpers
      .assessor_interface_application_forms_path(params[:search]&.permit!)
  end

  attr_reader :params
end
