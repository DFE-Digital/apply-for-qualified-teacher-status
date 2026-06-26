# frozen_string_literal: true

class Staff::UnlocksController < Devise::UnlocksController
  include AssessorCurrentNamespace

  before_action :redirect_to_home

  layout "two_thirds"

  # GET /resource/unlock/new
  # def new
  #   super
  # end

  # POST /resource/unlock
  # def create
  #   super
  # end

  # GET /resource/unlock?unlock_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after sending unlock password instructions
  # def after_sending_unlock_instructions_path_for(resource)
  #   super(resource)
  # end

  # The path used after unlocking the resource
  # def after_unlock_path_for(resource)
  #   super(resource)
  # end
  def redirect_to_home
    if FeatureFlags::FeatureFlag.active?(:sign_in_with_active_directory)
      redirect_to root_path
    end
  end
end
