# frozen_string_literal: true

module TeacherInterface
  class PassportDocumentController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    skip_before_action :track_history, only: :show
    define_history_check :check

    def show
      if application_form.passport_document_status_completed?
        redirect_to %i[
                      check
                      teacher_interface
                      application_form
                      passport_document
                    ]
      else
        redirect_to %i[
                      expiry_date
                      teacher_interface
                      application_form
                      passport_document
                    ]
      end
    end

    def expiry_date
      @form =
        PassportExpiryDateForm.new(
          passport_expiry_date: application_form.passport_expiry_date,
        )
    end

    def update_expiry_date
      @form =
        PassportExpiryDateForm.new(
          passport_expiry_date_form_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: [
          :teacher_interface,
          :application_form,
          application_form.passport_document,
        ],
        if_failure_then_render: :expiry_date,
      )
    end

    def check
    end

    private

    def passport_expiry_date_form_params
      params.require(:teacher_interface_passport_expiry_date_form).permit(
        :passport_expiry_date,
      )
    end
  end
end
