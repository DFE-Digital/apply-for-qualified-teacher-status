# frozen_string_literal: true

class Staff::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_support!

  def entra_id
    auth = request.env["omniauth.auth"]
    email = auth["info"]["email"]
    azure_ad_uid = auth["uid"]

    return fail_sign_in if azure_ad_uid.blank?

    staff = Staff.find_by(azure_ad_uid:)

    if staff.nil?
      staff = Staff.find_by_email(email)

      if staff.present? && staff.azure_ad_uid.nil?
        staff.update!(azure_ad_uid:)
        staff.confirm unless staff.confirmed?

        sign_in_and_redirect staff, event: :authentication
      else
        fail_sign_in
      end
    else
      staff.confirm unless staff.confirmed?
      sign_in_and_redirect staff, event: :authentication
    end
  end

  protected

  def fail_sign_in
    redirect_to root_url, alert: t(".failure")
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || assessor_interface_root_path
  end

  def after_omniauth_failure_path_for(_scope)
    root_url
  end
end
