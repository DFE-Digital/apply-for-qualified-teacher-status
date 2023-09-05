# frozen_string_literal: true

class SupportInterface::StaffController < SupportInterface::BaseController
  before_action :load_staff, except: :index

  def index
    authorize [:support_interface, Staff]
    @staff = Staff.order(:name)
  end

  def edit
  end

  def update
    if @staff.update(staff_params)
      redirect_to %i[support_interface staff index]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_staff
    @staff = Staff.find(params[:id])
    authorize [:support_interface, @staff]
  end

  def staff_params
    params.require(:staff).permit(
      :award_decline_permission,
      :change_work_history_permission,
      :reverse_decision_permission,
      :support_console_permission,
      :withdraw_permission,
    )
  end
end
