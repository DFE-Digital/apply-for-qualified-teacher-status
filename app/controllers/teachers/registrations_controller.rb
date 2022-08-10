# frozen_string_literal: true

class Teachers::RegistrationsController < Devise::RegistrationsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  def create
    if (resource = Teacher.find_by(email: sign_up_params[:email]))
      if resource.active_for_authentication?
        resource.send_magic_link
      else
        resource.resend_confirmation_instructions
      end

      redirect_to teacher_check_email_path
    else
      super
    end
  end

  def update
    redirect_to new_teacher_session_path
  end

  protected

  def after_inactive_sign_up_path_for(_resource)
    teacher_check_email_path
  end
end
