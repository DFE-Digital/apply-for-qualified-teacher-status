# frozen_string_literal: true

class Teachers::ConfirmationsController < Devise::ConfirmationsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      sign_in(resource)
      respond_with_navigational(resource) do
        redirect_to after_confirmation_path_for(resource_name, resource)
      end
    else
      set_flash_message!(:notice, :already_confirmed)
      redirect_to :create_or_new_teacher_session
    end
  end

  protected

  def after_confirmation_path_for(_resource_name, _resource)
    teacher_interface_application_form_path
  end
end
