# frozen_string_literal: true

module AssessorInterface
  class ApplicationFormsController < BaseController
    include ActionController::Live
    include HistoryTrackable
    include CSVStreamable

    before_action only: %i[index apply_filters apply_sort clear_filters] do
      authorize %i[assessor_interface application_form]
    end

    before_action except: %i[index apply_filters apply_sort clear_filters] do
      authorize [:assessor_interface, application_form]
    end

    define_history_origin :index, :show
    define_history_reset :index

    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:, session:)

      respond_to do |format|
        format.html { render layout: "full_from_desktop" }

        format.csv do
          set_csv_headers(filename: "applications-#{Time.current.iso8601}.csv")
          stream_csv(
            data: @view_object.application_forms_result,
            csv_content_class: ApplicationFormsExportContent,
          )
        end
      end
    end

    def apply_filters
      session[:filter_params] = extract_filter_params(
        remove_cleared_autocomplete_values(params),
      )
      redirect_to assessor_interface_application_forms_path
    end

    def apply_sort
      session[:sort_params] = extract_sort_params(params)
      redirect_to assessor_interface_application_forms_path
    end

    def clear_filters
      session[:filter_params] = {}
      redirect_to assessor_interface_application_forms_path
    end

    def show
      @view_object = show_view_object
    end

    def status
      @view_object = show_view_object
    end

    def timeline
      @view_object = show_view_object

      @timeline_events =
        TimelineEvent
          .includes(:assignee, :assessment_section, :note)
          .where(application_form: @application_form)
          .order(created_at: :desc)
    end

    def edit_email
      @form = ApplicationFormEmailForm.new
    end

    def update_email
      @form =
        ApplicationFormEmailForm.new(
          email_form_params.merge(application_form:, user: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :edit_email, status: :unprocessable_entity
      end
    end

    def edit_name
      @form = ApplicationFormNameForm.new
    end

    def update_name
      @form =
        ApplicationFormNameForm.new(
          name_form_params.merge(application_form:, user: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :edit_name, status: :unprocessable_entity
      end
    end

    def withdraw
    end

    def destroy
      WithdrawApplicationForm.call(application_form:, user: current_staff)
      redirect_to [:assessor_interface, application_form]
    end

    private

    def extract_filter_params(params)
      params[:assessor_interface_filter_form].permit!.to_h
    end

    def extract_sort_params(params)
      params[:assessor_interface_sort_form].permit!.to_h
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

    def email_form_params
      params.require(:assessor_interface_application_form_email_form).permit(
        :email,
      )
    end

    def name_form_params
      params.require(:assessor_interface_application_form_name_form).permit(
        :given_names,
        :family_name,
      )
    end
  end
end
