# frozen_string_literal: true

class Teachers::OmniauthCallbacksController < ApplicationController
  def gov_one
    auth = request.env["omniauth.auth"]
    email = auth&.info&.email
    gov_one_id = auth&.uid

    session[:id_token] = auth&.credentials&.id_token

    teacher =
      FindOrCreateTeacherFromGovOne.call(
        email:,
        gov_one_id:,
        eligibility_check_id: session[:eligibility_check_id],
      )

    return error_redirect unless teacher

    sign_in_and_redirect teacher
  end

  def failure
    error_redirect
  end

  private

  def error_redirect
    return if teacher_signed_in?

    flash[:alert] = "There was a problem signing in. Please try again."
    redirect_to new_teacher_session_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end
end
