# frozen_string_literal: true

module StreamedResponseAuthenticatable
  extend ActiveSupport::Concern

  # ActionController::Live module changes the "process" method
  # so that it runs inside a spawn thread.
  # The "process" method will also handle all filters (before/around/after action hooks).
  # Usually the authentication happens in a before action filter
  # and if the user is not authentication Devise will throw :warden

  def authenticate_or_redirect(scope)
    redirect_to failure_redirect_for(scope) unless authenticated_user(scope)
  end

  def authenticated_user(scope)
    catch(:warden) do
      user = send("authenticate_#{scope}!")
      return user
    end
    nil
  end

  def failure_redirect_for(scope)
    if scope == :staff
      omniauth_authorize_path(:staff, :entra_id)
    else
      [:new, scope, :session]
    end
  end
end
