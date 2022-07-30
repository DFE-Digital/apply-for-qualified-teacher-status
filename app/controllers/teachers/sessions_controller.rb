# frozen_string_literal: true

class Teachers::SessionsController < Devise::SessionsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  def create
    if resource_params[:create_or_sign_in] == "create"
      redirect_to :eligibility_interface_countries
      return
    end

    self.resource = resource_class.find_by(email: resource_params[:email])

    if resource
      if resource.active_for_authentication?
        resource.send_magic_link(resource_params[:remember_me])
      else
        resource.resend_confirmation_instructions
      end

      redirect_to :teacher_check_email
    else
      set_flash_message(:alert, :not_found_in_database, now: true)
      self.resource = resource_class.new(email: resource_params[:email])
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
end
