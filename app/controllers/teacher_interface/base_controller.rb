class TeacherInterface::BaseController < ApplicationController
  include TeacherCurrentNamespace

  layout "two_thirds"

  before_action :authenticate_teacher!

  def load_application_form
    @application_form =
      ApplicationForm.where(teacher: current_teacher).find(
        params[:application_form_id] || params[:id]
      )
  end
end
