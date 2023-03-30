# frozen_string_literal: true

class Teachers::MagicLinksController < DeviseController
  include TeacherCurrentNamespace

  prepend_before_action :require_no_authentication, only: :show
  prepend_before_action :allow_params_authentication!, only: :show
  prepend_before_action(only: [:show]) do
    request.env["devise.skip_timeout"] = true
  end

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

  def auth_options
    mapping = Devise.mappings[resource_name]
    { scope: resource_name, recall: "#{mapping.controllers[:sessions]}#new" }
  end

  def translation_scope
    "devise.sessions"
  end

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end
end
