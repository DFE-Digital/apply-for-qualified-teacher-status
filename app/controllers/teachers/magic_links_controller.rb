# frozen_string_literal: true

class Teachers::MagicLinksController < Devise::MagicLinksController
  include TeacherCurrentNamespace

  def show
    @resource = warden.authenticate!(auth_options)
    redirect_to new_teacher_session_path if @resource.nil?
  end

  def create
    resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    redirect_to after_sign_in_path_for(resource)
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end
end
