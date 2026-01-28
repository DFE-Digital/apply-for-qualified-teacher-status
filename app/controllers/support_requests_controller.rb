# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :error_not_found

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

  attr_reader :reference_request

  def form_params
    params.require(:support_request_form).permit(
      :name,
      :email,
      :comment,
      :category_type,
      :application_reference,
      :application_enquiry_type,
    )
  end

  def current_namespace
    current_teacher ? "teacher" : "eligibility"
  end
end
