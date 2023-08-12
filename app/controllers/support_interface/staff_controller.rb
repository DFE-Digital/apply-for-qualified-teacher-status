# frozen_string_literal: true

class SupportInterface::StaffController < SupportInterface::BaseController
  def index
    @staff = Staff.order(:name)
  end

  def edit
    @staff = Staff.find(params[:id])
  end

  def update
    @staff = Staff.find(params[:id])

    if @staff.update(staff_params)
      redirect_to %i[support_interface staff index]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def staff_params
    params.require(:staff).permit(
      :award_decline_permission,
      :manage_applications_permission,
      :reverse_decision_permission,
      :support_console_permission,
      :withdraw_permission,
    )
  end
end
