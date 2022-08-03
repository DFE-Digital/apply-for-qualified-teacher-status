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
        documentable: [application_form] + application_form.qualifications
      ).find(params[:document_id] || params[:id])
  end

  def redirect_to_if_save_and_continue(*args)
    if params[:next] == "save_and_continue"
      redirect_to(*args)
    else
      redirect_to [:teacher_interface, application_form]
    end
  end
end
