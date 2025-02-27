# frozen_string_literal: true

class AssessorInterface::StaffController < AssessorInterface::BaseController
  before_action :load_staff, except: :index

  def index
    authorize [:support_interface, Staff]
    @staff = Staff.not_archived.order(:name)
  end

  private

  def load_staff
    @staff = Staff.find(params[:id])
    authorize [:support_interface, @staff]
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
    )
  end
end
