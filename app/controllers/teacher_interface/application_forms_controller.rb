# frozen_string_literal: true

module TeacherInterface
  class ApplicationFormsController < BaseController
    include HistoryTrackable

    before_action :redirect_if_application_form_active, only: %i[new create]
    before_action :redirect_unless_application_form_is_draft,
                  only: %i[edit update]
    before_action :load_application_form, except: %i[new create]

    define_history_origin :show
    define_history_reset :show
    define_history_check :edit

    def new
      @already_applied = application_form.present?
      @needs_region = false

      @country_region_form =
        CountryRegionForm.new(
          location: CountryCode.to_location(application_form&.country&.code),
        )
    end

    def create
      @already_applied = application_form.present?

      @country_region_form =
        CountryRegionForm.new(
          country_region_form_params.merge(teacher: current_teacher),
        )

      if @country_region_form.needs_region?
        @needs_region = true
        render :new
      elsif @country_region_form.save(validate: true)
        redirect_to teacher_interface_application_form_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      if application_form.nil?
        redirect_to %i[new teacher_interface application_form]
      end

      @view_object = ApplicationFormViewObject.new(application_form:)
    end

    def edit
      @view_object = ApplicationFormViewObject.new(application_form:)

      @sanction_confirmation_form =
        SanctionConfirmationForm.new(
          application_form:,
          confirmed_no_sanctions: application_form.confirmed_no_sanctions,
        )
    end

    def update
      @view_object = ApplicationFormViewObject.new(application_form:)

      if (
           @sanction_confirmation_form =
             SanctionConfirmationForm.new(
               application_form:,
               confirmed_no_sanctions:
                 application_form_params[:confirmed_no_sanctions],
             )
         ).save(validate: true)
        SubmitApplicationForm.call(application_form:, user: current_teacher)
        redirect_to %i[teacher_interface application_form]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def redirect_if_application_form_active
      if application_form.present? && !application_form.completed_stage?
        redirect_to %i[teacher_interface application_form]
      end
    end

    def country_region_form_params
      params.require(:teacher_interface_country_region_form).permit(
        :location,
        :region_id,
      )
    end

    def application_form_params
      params.fetch(:teacher_interface_sanction_confirmation_form, {}).permit(
        :confirmed_no_sanctions,
      )
    end
  end
end
