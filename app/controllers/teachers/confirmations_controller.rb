# frozen_string_literal: true

class Teachers::ConfirmationsController < Devise::ConfirmationsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      sign_in(resource)
      respond_with_navigational(resource) do
        redirect_to after_confirmation_path_for(resource_name, resource)
      end
    else
      respond_with_navigational(
        resource.errors,
        status: :unprocessable_entity
      ) { render :new }
    end
  end

  protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  def after_confirmation_path_for(resource_name, resource)
    stored_location_for(resource) || super
  end
end
