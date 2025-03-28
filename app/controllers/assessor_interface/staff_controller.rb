# frozen_string_literal: true

class AssessorInterface::StaffController < AssessorInterface::BaseController
  before_action :load_staff, except: :index

  def index
    authorize [:assessor_interface, Staff]
    @active_staff = Staff.not_archived.order(:name)
    @archived_staff = Staff.archived.order(:name)
    render layout: "full_from_desktop"
  end

  def edit
  end

  def update
    if @staff.update(staff_params)
      redirect_to %i[assessor_interface staff index]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_staff
    @staff = Staff.find(params[:id])
    authorize [:assessor_interface, @staff]
  end

  def staff_params
    params.require(:staff).permit(
      :assess_permission,
      :change_name_permission,
      :change_work_history_permission,
      :reverse_decision_permission,
      :support_console_permission,
      :verify_permission,
      :withdraw_permission,
      :manage_staff_permission,
    )
  end
end
