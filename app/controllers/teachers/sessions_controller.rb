# frozen_string_literal: true

class Teachers::SessionsController < Devise::SessionsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  def create
    self.resource = resource_class.find_by(email: create_params[:email])
    if resource
      resource.send_magic_link(create_params[:remember_me])
      redirect_to :teacher_check_email
      return
    end

    set_flash_message(:alert, :not_found_in_database, now: true)
    self.resource = resource_class.new(create_params)
    render :new
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
    resource_params.permit(:email, :remember_me)
  end
end
