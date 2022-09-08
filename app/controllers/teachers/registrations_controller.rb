# frozen_string_literal: true

class Teachers::RegistrationsController < Devise::RegistrationsController
  include TeacherCurrentNamespace

  after_action :create_application_form, only: :create

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

  def set_flash_message(*args, **kwargs)
    # We want to disable the built-in Devise flash messages for teachers.
  end

  def after_inactive_sign_up_path_for(_resource)
    teacher_check_email_path
  end

  def create_application_form
    if valid_eligibility_check? && teacher_requires_application_form?
      ApplicationFormFactory.call(
        teacher: resource,
        region: eligibility_check.region
      )
    end
  end

  def valid_eligibility_check?
    eligibility_check.present? && eligibility_check.region.present?
  end

  def eligibility_check
    @eligibility_check ||=
      EligibilityCheck.find_by(id: session[:eligibility_check_id])
  end

  def teacher_requires_application_form?
    resource.application_form.nil?
  end
end
