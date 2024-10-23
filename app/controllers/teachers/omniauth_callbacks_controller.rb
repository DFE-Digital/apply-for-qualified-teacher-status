# frozen_string_literal: true

class Teachers::OmniauthCallbacksController < ApplicationController
  def gov_one
    auth = request.env["omniauth.auth"]
    email = auth&.info&.email
    gov_one_id = auth&.uid

    return error_redirect unless email

    if new_user_without_eligibility_check_completed?(email)
      redirect_to :eligibility_interface_countries
    else
      session[:id_token] = auth&.credentials&.id_token

      teacher =
        FindOrCreateTeacherFromGovOne.call(
          email:,
          gov_one_id:,
          eligibility_check:,
        )

      return error_redirect unless teacher

      sign_in_and_redirect teacher
    end
  end

  def failure
    error_redirect
  end

  private

  def new_user_without_eligibility_check_completed?(email)
    Teacher.find_by(email:).nil? &&
      (
        eligibility_check.nil? || !eligibility_check.completed? ||
          !eligibility_check.eligible?
      )
  end

  def eligibility_check
    @eligibility_check ||=
      EligibilityCheck.find_by(id: session[:eligibility_check_id])
  end

  def error_redirect
    return if teacher_signed_in?

    flash[:alert] = "There was a problem signing in. Please try again."
    redirect_to root_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end
end
