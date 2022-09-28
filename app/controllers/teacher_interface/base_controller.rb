class TeacherInterface::BaseController < ApplicationController
  include TeacherCurrentNamespace

  layout "two_thirds"

  before_action :authenticate_teacher!

  def load_application_form
    @application_form = application_form
  end

  def load_document
    @document = document
  end

  def application_form
    @application_form ||= current_teacher.application_form
  end

  def document
    @document ||=
      Document.where(
        documentable:
          [application_form] + application_form.qualifications +
            (
              application_form
                .assessment
                &.further_information_requests
                &.flat_map(&:items) || []
            ),
      ).find(params[:document_id] || params[:id])
  end

  def redirect_to_if_save_and_continue(*args)
    if params[:next] == "save_and_continue"
      redirect_to(*args)
    else
      redirect_to %i[teacher_interface application_form]
    end
  end

  def redirect_unless_application_form_is_draft
    unless application_form.draft?
      redirect_to %i[teacher_interface application_form]
    end
  end

  def redirect_unless_draft_or_further_information
    if document.further_information_request?
      unless document.documentable.further_information_request.requested?
        redirect_to %i[teacher_interface application_form]
      end
    else
      redirect_unless_application_form_is_draft
    end
  end
end
