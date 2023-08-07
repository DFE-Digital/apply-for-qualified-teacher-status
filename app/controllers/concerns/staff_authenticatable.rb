# frozen_string_literal: true

module StaffAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_staff!
    alias_method :pundit_user, :current_staff
  end

  def authenticate_staff!
    if staff_signed_in? ||
         !FeatureFlags::FeatureFlag.active?(:sign_in_with_active_directory)
      super
    else
      session[:staff_return_to] = request.fullpath
      redirect_to omniauth_authorize_path(:staff, :azure_activedirectory_v2)
    end
  end
end
