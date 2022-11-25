module AssessorInterface
  class ApplicationFormsController < BaseController
    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:, session:)
      render layout: "full_from_desktop"
    end

    def apply_filters
      session[:filter_params] = extract_filter_params(
        remove_cleared_autocomplete_values(params),
      )
      redirect_to assessor_interface_application_forms_path(page: params[:page])
    end

    def clear_filters
      session[:filter_params] = {}
      redirect_to assessor_interface_application_forms_path(page: params[:page])
    end

    def show
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end

    def status
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end

    private

    def extract_filter_params(params)
      params[:assessor_interface_filter_form].permit!
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
