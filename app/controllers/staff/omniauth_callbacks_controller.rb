class Staff::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def azure_activedirectory_v2
    auth = request.env["omniauth.auth"]
    email = auth["info"]["email"]
    provider = auth["provider"]
    uid = auth["uid"]

    @staff = Staff.find_by(email:, provider: "azure_activedirectory_v2")

    if @staff&.update(provider:, uid:)
      sign_in_and_redirect @staff, event: :authentication
    else
      redirect_to new_staff_session_url, alert: t(".failure")
    end
  end

  def failure
    redirect_to root_path, alert: "Authentication failed, please try again."
  end
end
