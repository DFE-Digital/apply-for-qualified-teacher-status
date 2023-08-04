# frozen_string_literal: true

module AssessorInterface
  class ApplicationFormsController < BaseController
    def index
      authorize %i[assessor_interface application_form], :index?
      @view_object = ApplicationFormsIndexViewObject.new(params:, session:)
      render layout: "full_from_desktop"
    end

    def apply_filters
      authorize %i[assessor_interface application_form], :index?
      session[:filter_params] = extract_filter_params(
        remove_cleared_autocomplete_values(params),
      )
      redirect_to assessor_interface_application_forms_path
    end

    def clear_filters
      authorize %i[assessor_interface application_form], :index?
      session[:filter_params] = {}
      redirect_to assessor_interface_application_forms_path
    end

    def show
      authorize [:assessor_interface, application_form]
      @view_object = show_view_object
    end

    def status
      authorize [:assessor_interface, application_form], :show?
      @view_object = show_view_object
    end

    def withdraw
      authorize [:assessor_interface, application_form]
    end

    def destroy
      authorize [:assessor_interface, application_form]
      WithdrawApplicationForm.call(application_form:, user: current_staff)
      redirect_to [:assessor_interface, application_form]
    end

    private

    def extract_filter_params(params)
      params[:assessor_interface_filter_form].permit!.to_h
    end

    def remove_cleared_autocomplete_values(params)
      if params.include?(:location_autocomplete) &&
           params[:location_autocomplete].blank?
        params[:assessor_interface_filter_form]&.delete(:location)
      end

      params
    end

    def show_view_object
      @show_view_object =
        ApplicationFormsShowViewObject.new(params:, current_staff:)
    end

    def application_form
      @application_form ||= show_view_object.application_form
    end
  end
end
