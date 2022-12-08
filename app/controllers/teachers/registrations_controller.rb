# frozen_string_literal: true

class Teachers::RegistrationsController < Devise::RegistrationsController
  include TeacherCurrentNamespace

  after_action :create_application_form, only: :create

  layout "two_thirds"

  def create
    self.resource = Teacher.find_or_initialize_by(sign_up_params)

    if resource.save
      resource.create_otp
      resource.send_otp
      redirect_to new_teacher_otp_path(uuid: resource.reload.uuid)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    redirect_to :create_or_new_teacher_session
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
        region: eligibility_check.region,
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
    resource.persisted? && resource.application_form.nil?
  end
end
