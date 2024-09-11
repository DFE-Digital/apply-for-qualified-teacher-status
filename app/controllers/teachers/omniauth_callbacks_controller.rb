class Teachers::OmniauthCallbacksController < ApplicationController
  def gov_one
  end

  def failure
    error_redirect
  end

  private

  def error_redirect
    return if teacher_signed_in?

    flash[:alert] = 'There was a problem signing in. Please try again.'
    redirect_to new_teacher_session_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end
end