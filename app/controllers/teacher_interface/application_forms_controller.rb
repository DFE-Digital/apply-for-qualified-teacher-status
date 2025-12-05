# frozen_string_literal: true

module TeacherInterface
  class ApplicationFormsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_if_application_form_active, only: %i[create reapply]
    before_action :redirect_unless_application_form_is_draft,
                  only: %i[edit update]
    before_action :load_application_form, except: %i[create]
    before_action :update_application_and_redirect_if_passport_expired,
                  only: %i[edit update]
    before_action :update_application_and_redirect_if_any_referee_has_public_email_domain,
                  only: %i[edit update]

    define_history_origin :show
    define_history_reset :show
    define_history_check :edit

    def create
      eligibility_check =
        EligibilityCheck.find_by(id: session[:eligibility_check_id])

      if eligibility_check && eligibility_check.region
        ApplicationFormFactory.call(
          teacher: current_teacher,
          region: eligibility_check.region,
          eligibility_check:,
        )

        redirect_to %i[teacher_interface application_form]
      else
        redirect_to %i[eligibility_interface countries]
      end
    end

    def show
      redirect_to %i[eligibility_interface countries] if application_form.nil?

      @view_object = ApplicationFormViewObject.new(application_form:)
    end

    def answers
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
        send_errors_to_big_query(@sanction_confirmation_form)

        render :edit, status: :unprocessable_entity
      end
    end

    def reapply
      if application_form.present? && application_form.declined?
        session[:reapplication_flow] = true

        redirect_to %i[eligibility_interface countries]
      else
        redirect_to %i[teacher_interface application_form]
      end
    end

    private

    def redirect_if_application_form_active
      return if application_form.blank?

      view_object = ApplicationFormViewObject.new(application_form:)

      if !application_form.completed_stage? ||
           view_object.declined_cannot_reapply?
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

    def update_application_and_redirect_if_passport_expired
      unless application_form.requires_passport_as_identity_proof? &&
               application_form.passport_expiry_date.present?
        return
      end

      if application_form.passport_expiry_date < Date.current
        ApplicationFormSectionStatusUpdater.call(application_form:)

        redirect_to teacher_interface_application_form_path
      end
    end

    def update_application_and_redirect_if_any_referee_has_public_email_domain
      if requires_private_email_for_referee? &&
           application_form.work_histories.any?(
             &:invalid_email_domain_for_contact?
           )
        ApplicationFormSectionStatusUpdater.call(application_form:)

        redirect_to teacher_interface_application_form_path
      end
    end

    def requires_private_email_for_referee?
      FeatureFlags::FeatureFlag.active?(:email_domains_for_referees)
    end
  end
end
