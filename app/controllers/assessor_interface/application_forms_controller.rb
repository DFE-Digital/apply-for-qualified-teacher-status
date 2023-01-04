# frozen_string_literal: true

module AssessorInterface
  class ApplicationFormsController < BaseController
    before_action :authorize_assessor,
                  except: %i[apply_filters clear_filters status]

    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:, session:)
      render layout: "full_from_desktop"
    end

    def apply_filters
      authorize :assessor, :index?
      session[:filter_params] = extract_filter_params(
        remove_cleared_autocomplete_values(params),
      )
      redirect_to assessor_interface_application_forms_path
    end

    def clear_filters
      authorize :assessor, :index?
      session[:filter_params] = {}
      redirect_to assessor_interface_application_forms_path
    end

    def show
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end

    def status
      authorize :assessor, :show?
      @view_object = ApplicationFormsShowViewObject.new(params:)
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
  end
end
