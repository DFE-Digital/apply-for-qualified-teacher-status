class Staff::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def azure_activedirectory_v2
    auth = request.env["omniauth.auth"]
    email = auth["info"]["email"]
    azure_ad_uid = auth["uid"]

    @staff = Staff.find_by_email(email)

    if @staff&.update(azure_ad_uid:)
      @staff.confirm unless @staff.confirmed?
      sign_in_and_redirect @staff, event: :authentication
    else
      redirect_to new_staff_session_url, alert: t(".failure")
    end
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || assessor_interface_root_path
  end

  def after_omniauth_failure_path_for(_scope)
    new_staff_session_url
  end
end
