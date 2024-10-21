# frozen_string_literal: true

class Teachers::RegistrationsController < Devise::RegistrationsController
  include TeacherCurrentNamespace

  before_action :redirect_to_gov_one_login,
                if: :gov_one_applicant_login_feature_active?
  after_action :create_application_form, only: :create

  layout "two_thirds"

  def create
    self.resource = Teacher.find_or_initialize_by_email(sign_up_params[:email])

    if resource.save
      resource.send_magic_link
      redirect_to teacher_check_email_path(email: resource.email)
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
    eligibility_check.present? && eligibility_check.region.present? &&
      eligibility_check.country.eligibility_enabled?
  end

  def eligibility_check
    @eligibility_check ||=
      EligibilityCheck.find_by(id: session[:eligibility_check_id])
  end

  def teacher_requires_application_form?
    resource.persisted? && resource.application_form.nil?
  end

  def redirect_to_gov_one_login
    redirect_to "/teacher/auth/gov_one"
  end

  def gov_one_applicant_login_feature_active?
    FeatureFlags::FeatureFlag.active?(:gov_one_applicant_login)
  end
end
