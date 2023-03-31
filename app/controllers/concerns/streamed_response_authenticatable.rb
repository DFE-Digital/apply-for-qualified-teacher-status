# frozen_string_literal: true

module StreamedResponseAuthenticatable
  extend ActiveSupport::Concern

  # ActionController::Live module changes the "process" method
  # so that it runs inside a spawn thread.
  # The "process" method will also handle all filters (before/around/after action hooks).
  # Usually the authentication happens in a before action filter
  # and if the user is not authentication Devise will throw :warden

  def authenticate_or_redirect(scope)
    redirect_to [:new, scope, :session] unless authenticated_user(scope)
  end

  def authenticated_user(scope)
    catch(:warden) do
      user = send("authenticate_#{scope}!")
      return user
    end
    nil
  end
end
