# frozen_string_literal: true

module AssessorInterface
  class DraftApplicationFormsController < BaseController
    before_action only: %i[index apply_filters clear_filters] do
      authorize %i[assessor_interface application_form]
    end

    def index
      @view_object = DraftApplicationFormsIndexViewObject.new(params:, session:)
    end

    def show
      application_form =
        ApplicationForm.draft_stage.find_by!(reference: params[:reference])
      authorize [:assessor_interface, application_form]
    end

    def apply_filters
      session[:draft_filter_params] = params
        .require(:assessor_interface_draft_application_forms_filter_form)
        .permit(:email)
        .to_h
      redirect_to assessor_interface_draft_application_forms_path
    end

    def clear_filters
      session[:draft_filter_params] = {}
      redirect_to assessor_interface_draft_application_forms_path
    end
  end
end
