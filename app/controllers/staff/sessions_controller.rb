class Staff::SessionsController < Devise::SessionsController
  include StaffCurrentNamespace

  layout "two_thirds"

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || assessor_interface_root_path
  end

  def after_sign_out_path_for(_resource)
    new_staff_session_path
  end
end
