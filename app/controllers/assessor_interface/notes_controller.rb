# frozen_string_literal: true

module AssessorInterface
  class NotesController < BaseController
    before_action :authorize_note

    def new
      @application_form = application_form
      @create_note_form = CreateNoteForm.new
    end

    def create
      @application_form = application_form
      @create_note_form =
        CreateNoteForm.new(
          create_new_form_params.merge(application_form:, author:),
        )

      if @create_note_form.save!
        redirect_to params[:next].presence ||
                      [:assessor_interface, application_form]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def application_form
      @application_form ||= ApplicationForm.find(params[:application_form_id])
    end

    def author
      @author ||= current_staff
    end

    def create_new_form_params
      params.require(:assessor_interface_create_note_form).permit(:text)
    end
  end
end
