# frozen_string_literal: true
class Teachers::SessionsController < Devise::SessionsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  def new
    @new_session_form = TeacherInterface::NewSessionForm.new
  end

  def create
    @new_session_form =
      TeacherInterface::NewSessionForm.new(
        email: new_session_form_params[:email],
        create_or_sign_in: new_session_form_params[:create_or_sign_in]
      )

    if @new_session_form.valid?
      if @new_session_form.create?
        redirect_to :eligibility_interface_countries
        return
      end

      self.resource = resource_class.find_by(email: @new_session_form.email)

      if resource
        if resource.active_for_authentication?
          resource.send_magic_link
        else
          resource.resend_confirmation_instructions
        end
      end
      redirect_to :teacher_check_email
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new_session_form_params
    params.require(:teacher_interface_new_session_form).permit(
      :email,
      :create_or_sign_in
    )
  end

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    yield if block_given?
    respond_to_on_destroy
  end

  def check_email
  end

  def signed_out
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end

  def after_sign_out_path_for(_resource)
    teacher_signed_out_path
  end

  def translation_scope
    if action_name == "create"
      "devise.passwordless"
    else
      super
    end
  end
end
