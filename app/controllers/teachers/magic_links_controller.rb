# frozen_string_literal: true

class Teachers::MagicLinksController < DeviseController
  prepend_before_action :require_no_authentication, only: :show
  prepend_before_action :allow_params_authentication!, only: :show
  prepend_before_action(only: [:show]) do
    request.env["devise.skip_timeout"] = true
  end

  layout "two_thirds"

  def show
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
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

  def create_params
    resource_params.permit(:email, :remember_me)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end
end
