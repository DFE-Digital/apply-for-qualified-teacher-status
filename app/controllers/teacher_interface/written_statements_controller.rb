# frozen_string_literal: true

module TeacherInterface
  class WrittenStatementsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def edit
      @form =
        WrittenStatementConfirmationForm.new(
          application_form:,
          written_statement_confirmation:
            application_form.written_statement_confirmation,
        )
    end

    def update
      @form =
        WrittenStatementConfirmationForm.new(
          written_statement_confirmation_form_params.merge(application_form:),
        )

      handle_application_form_section(form: @form)
    end

    private

    def written_statement_confirmation_form_params
      params.fetch(
        :teacher_interface_written_statement_confirmation_form,
        {},
      ).permit(:written_statement_confirmation)
    end
  end
end
