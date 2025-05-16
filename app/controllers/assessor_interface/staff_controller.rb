# frozen_string_literal: true

class AssessorInterface::StaffController < AssessorInterface::BaseController
  before_action :load_staff, except: :index

  def index
    authorize [:assessor_interface, Staff]
    @active_staff = Staff.not_archived.order(updated_at: :desc)
    @archived_staff = Staff.archived.order(updated_at: :desc)
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

  def update_archive
    if @staff.update(archived: true)
      flash[:success] = "#{@staff.name} has been archived"
      redirect_to "#{assessor_interface_staff_index_path}#archived-users"
    else
      flash[:warning] = "Unable to archive staff"
      redirect_to assessor_interface_staff_index_path
    end
  end

  def edit_archive
  end

  def update_unarchive
    if @staff.update(archived: false)
      flash[:success] = "#{@staff.name} has been reactivated"
      redirect_to assessor_interface_staff_index_path
    else
      flash[:warning] = "Unable to reactivate staff"
      redirect_to "#{assessor_interface_staff_index_path}#archived-users"
    end
  end

  def edit_unarchive
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
      :change_work_history_and_qualification_permission,
      :reverse_decision_permission,
      :support_console_permission,
      :verify_permission,
      :withdraw_permission,
      :manage_staff_permission,
    )
  end
end
