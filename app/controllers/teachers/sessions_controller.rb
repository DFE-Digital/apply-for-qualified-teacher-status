# frozen_string_literal: true

class Teachers::SessionsController < Devise::SessionsController
  include TeacherCurrentNamespace

  before_action :redirect_to_gov_one_login,
                if: :gov_one_applicant_login_feature_active?,
                only: [:new]

  layout "two_thirds"

  def new
    @new_session_form =
      TeacherInterface::NewSessionForm.new(sign_in_or_sign_up: "sign_in")
  end

  def new_or_create
    @new_session_form = TeacherInterface::NewSessionForm.new
  end

  def create
    if gov_one_applicant_login_feature_active?
      handle_login_with_gov_one
    else
      handle_login_with_magic_link
    end
  end

  def destroy
    teacher = current_teacher
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    yield if block_given?
    redirect_to after_sign_out_path_for(teacher)
  end

  def check_email
    @email = params[:email]
  end

  def signed_out
    @section = params[:section]
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || teacher_interface_root_path
  end

  def after_sign_out_path_for(resource)
    if (application_form = resource.try(:application_form))
      view_object =
        TeacherInterface::ApplicationFormViewObject.new(application_form:)

      section =
        if view_object.request_qualification_consent?
          "qualification_consent"
        else
          "application"
        end

      teacher_signed_out_path(section:)
    else
      teacher_signed_out_path
    end
  end

  private

  def new_session_form_params
    params.require(:teacher_interface_new_session_form).permit(
      :email,
      :sign_in_or_sign_up,
    )
  end

  def redirect_to_gov_one_login
    redirect_to "/teacher/auth/gov_one"
  end

  def gov_one_applicant_login_feature_active?
    FeatureFlags::FeatureFlag.active?(:gov_one_applicant_login)
  end

  def handle_login_with_gov_one
    @new_session_form =
      TeacherInterface::NewSessionForm.new(
        sign_in_or_sign_up: new_session_form_params[:sign_in_or_sign_up],
      )

    if @new_session_form.valid?
      if @new_session_form.sign_up?
        redirect_to :eligibility_interface_countries
      else
        redirect_to_gov_one_login
      end
    else
      render :new_or_create, status: :unprocessable_entity
    end
  end

  def handle_login_with_magic_link
    @new_session_form =
      TeacherInterface::NewSessionForm.new(
        email: new_session_form_params[:email],
        sign_in_or_sign_up: new_session_form_params[:sign_in_or_sign_up],
        validate_email: true,
      )

    if @new_session_form.valid?
      if @new_session_form.sign_up?
        redirect_to :eligibility_interface_countries
        return
      end

      self.resource = resource_class.find_by_email(@new_session_form.email)

      if resource
        resource.send_magic_link
        redirect_to teacher_check_email_path(email: resource.email)
      else
        redirect_to :eligibility_interface_countries
      end
    elsif @new_session_form.sign_in_or_sign_up.blank?
      render :new_or_create, status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end
end
