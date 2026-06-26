# frozen_string_literal: true

class Staff::ConfirmationsController < Devise::ConfirmationsController
  include AssessorCurrentNamespace

  before_action :redirect_to_home

  layout "two_thirds"

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end

  private

  def redirect_to_home
    if FeatureFlags::FeatureFlag.active?(:sign_in_with_active_directory)
      redirect_to root_path
    end
  end
end
