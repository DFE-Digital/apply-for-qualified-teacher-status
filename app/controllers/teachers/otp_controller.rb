# frozen_string_literal: true

class Teachers::OtpController < DeviseController
  include TeacherCurrentNamespace

  prepend_before_action :require_no_authentication, only: %i[new create]
  prepend_before_action :allow_params_authentication!, only: :create
  prepend_before_action(only: [:create]) do
    request.env["devise.skip_timeout"] = true
  end

  layout "two_thirds"

  def new
    @otp_form = Teachers::OtpForm.new(uuid: params[:uuid])
  end

  def create
    @otp_form = Teachers::OtpForm.new(user_params)

    if @otp_form.otp_expired? || !@otp_form.secret_key?
      fail_and_retry(reason: :expired)
    elsif @otp_form.valid?
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      yield resource if block_given?
      redirect_to after_sign_in_path_for(resource)
      resource.after_successful_otp_authentication
    elsif @otp_form.maximum_guesses?
      fail_and_retry(reason: :exhausted)
    else
      render :new
    end
  end

  def retry
    @error = params[:error]
  end

  protected

  def fail_and_retry(reason:)
    @otp_form.teacher.try(:after_failed_otp_authentication)
    redirect_to retry_teacher_otp_path(error: reason)
  end

  def auth_options
    mapping = Devise.mappings[resource_name]
    { scope: resource_name, recall: "#{mapping.path.pluralize}/sessions#new" }
  end

  def translation_scope
    "devise.sessions"
  end

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end

  def user_params
    params.require(:teacher).permit(:uuid, :otp, :email)
  end
end
