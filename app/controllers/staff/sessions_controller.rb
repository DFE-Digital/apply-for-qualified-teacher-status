class Staff::SessionsController < Devise::SessionsController
  include AssessorCurrentNamespace

  layout "two_thirds"

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
end
