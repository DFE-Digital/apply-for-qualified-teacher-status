# frozen_string_literal: true

class Teachers::SessionsController < Devise::SessionsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  def create
    if create_params[:create_or_sign_in] == "create"
      redirect_to :new_teacher_registration
      return
    end

    self.resource = resource_class.find_by(email: create_params[:email])

    if resource
      if resource.active_for_authentication?
        resource.send_magic_link(create_params[:remember_me])
      else
        resource.resend_confirmation_instructions
      end

      redirect_to :teacher_check_email
    else
      set_flash_message(:alert, :not_found_in_database, now: true)
      self.resource = resource_class.new(create_params)
      render :new
    end
  end

  def check_email
  end

  protected

  def translation_scope
    if action_name == "create"
      "devise.passwordless"
    else
      super
    end
  end

  private

  def create_params
    resource_params.permit(:email, :remember_me, :create_or_sign_in)
  end
end
