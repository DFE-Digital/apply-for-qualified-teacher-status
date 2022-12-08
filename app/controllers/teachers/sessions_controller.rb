# frozen_string_literal: true
class Teachers::SessionsController < Devise::SessionsController
  include TeacherCurrentNamespace

  layout "two_thirds"

  def new
    @new_session_form =
      TeacherInterface::NewSessionForm.new(sign_in_or_sign_up: "sign_in")
  end

  def new_or_create
    @new_session_form = TeacherInterface::NewSessionForm.new
  end

  def create
    @new_session_form =
      TeacherInterface::NewSessionForm.new(
        email: new_session_form_params[:email],
        sign_in_or_sign_up: new_session_form_params[:sign_in_or_sign_up],
      )

    if @new_session_form.valid?
      if @new_session_form.sign_up?
        redirect_to :eligibility_interface_countries
        return
      end

      self.resource = resource_class.find_by(email: @new_session_form.email)

      if resource
        resource.create_otp
        resource.send_otp
        redirect_to new_teacher_otp_path(uuid: resource.uuid)
      else
        redirect_to :eligibility_interface_countries
      end
    elsif @new_session_form.sign_in_or_sign_up.blank?
      render :new_or_create, status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new_session_form_params
    params.require(:teacher_interface_new_session_form).permit(
      :email,
      :sign_in_or_sign_up,
    )
  end

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    yield if block_given?
    respond_to_on_destroy
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
end
