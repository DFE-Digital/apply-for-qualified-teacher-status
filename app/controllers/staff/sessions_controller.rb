# frozen_string_literal: true

class Staff::SessionsController < Devise::SessionsController
  include AssessorCurrentNamespace

  layout "two_thirds"

  before_action :redirect_to_root, except: %i[destroy signed_out]

  def destroy
    super
  end

  def signed_out
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || assessor_interface_root_path
  end

  def after_sign_out_path_for(_resource)
    staff_signed_out_path
  end

  def set_flash_message(*)
    # Intentionally left blank
  end

  private

  def redirect_to_root
    redirect_to root_path
  end
end
