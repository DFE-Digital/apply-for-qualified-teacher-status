# frozen_string_literal: true

class Staff::PasswordsController < Devise::PasswordsController
  include AssessorCurrentNamespace

  before_action :redirect_to_home

  layout "two_thirds"

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  private

  def redirect_to_home
    if FeatureFlags::FeatureFlag.active?(:sign_in_with_active_directory)
      redirect_to root_path
    end
  end
end
