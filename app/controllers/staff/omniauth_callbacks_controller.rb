class Staff::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def azure_activedirectory_v2
    auth = request.env["omniauth.auth"]
    email = auth["info"]["email"]
    azure_ad_uid = auth["uid"]

    @staff = Staff.find_by(email:)

    if @staff&.update(azure_ad_uid:)
      @staff.confirm unless @staff.confirmed?
      sign_in_and_redirect @staff, event: :authentication
    else
      redirect_to new_staff_session_url, alert: t(".failure")
    end
  end

  def failure
    redirect_to new_staff_session_url, alert: t(".failure")
  end
end
