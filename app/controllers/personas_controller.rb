class PersonasController < ApplicationController
  before_action :ensure_feature_active

  layout "two_thirds"

  def index
    @staff = Staff.all
    @teachers = Teacher.all
  end

  def staff_sign_in
    staff = Staff.find(params[:id])
    sign_in_and_redirect(staff)
  end

  def teacher_sign_in
    teacher = Teacher.find(params[:id])
    sign_in_and_redirect(teacher)
  end

  protected

  def current_namespace
    "personas"
  end

  def after_sign_in_path_for(resource)
    case resource
    when Staff
      :assessor_interface_root
    when Teacher
      :teacher_interface_root
    end
  end

  private

  def ensure_feature_active
    unless FeatureFlag.active?(:personas)
      flash[:warning] = "Personas feature not active."
      redirect_to :root
    end
  end
end
