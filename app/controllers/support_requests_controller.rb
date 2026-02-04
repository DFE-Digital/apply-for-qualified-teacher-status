# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :ensure_feature_enabled

  def new
    @form = SupportRequestForm.new
  end

  def create
    @form = SupportRequestForm.new(form_params)

    if @form.save
      redirect_to confirmation_support_requests_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
  end

  private

  def form_params
    params.require(:support_request_form).permit(
      :name,
      :email,
      :comment,
      :user_type,
      :application_reference,
      :application_enquiry_type,
    )
  end

  def current_namespace
    current_teacher ? "teacher" : "eligibility"
  end

  def ensure_feature_enabled
    return if FeatureFlags::FeatureFlag.active?(:support_request_form)

    redirect_to root_path
  end
end
