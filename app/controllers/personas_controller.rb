class PersonasController < ApplicationController
  before_action :ensure_feature_active

  layout "two_thirds"

  def index
    @staff = Staff.all
    @teachers = Teacher.all
  end

  protected

  def current_namespace
    "personas"
  end

  private

  def ensure_feature_active
    unless FeatureFlag.active?(:personas)
      flash[:warning] = "Personas feature not active."
      redirect_to :root
    end
  end
end
