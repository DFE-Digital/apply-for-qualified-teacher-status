# frozen_string_literal: true

class Staff::SessionsController < Devise::SessionsController
  include AssessorCurrentNamespace

  before_action :redirect_to_home, except: %i[signed_out destroy]

  layout "two_thirds"

  def signed_out
  end

  def destroy
    super
  end

  protected

  def redirect_to_home
    if FeatureFlags::FeatureFlag.active?(:sign_in_with_active_directory)
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || assessor_interface_root_path
  end

  def after_sign_out_path_for(_resource)
    staff_signed_out_path
  end

  def set_flash_message(*)
    # Intentionally left blank
  end
end
