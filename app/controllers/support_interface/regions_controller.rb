# frozen_string_literal: true

class SupportInterface::RegionsController < SupportInterface::BaseController
  before_action :load_region

  def edit
  end

  def update
    @region.assign_attributes(region_params)
    if @region.invalid?
      render :edit, status: :unprocessable_entity
    elsif ActiveModel::Type::Boolean.new.cast(params[:preview])
      session[:region] = region_params
      redirect_to [:preview, :support_interface, @region]
    else
      @region.save!
      redirect_to %i[support_interface countries]
    end
  end

  def preview
    @region.assign_attributes(session[:region])
  end

  private

  def load_region
    @region = Region.find(params[:id])
    authorize [:support_interface, @region]
  end

  def region_params
    params.require(:region).permit(
      :application_form_skip_work_history,
      :qualifications_information,
      :reduced_evidence_accepted,
      :requires_preliminary_check,
      :sanction_check,
      :status_check,
      :teaching_authority_address,
      :teaching_authority_certificate,
      :teaching_authority_emails_string,
      :teaching_authority_name,
      :teaching_authority_online_checker_url,
      :teaching_authority_other,
      :teaching_authority_provides_written_statement,
      :teaching_authority_requires_submission_email,
      :teaching_authority_sanction_information,
      :teaching_authority_status_information,
      :teaching_authority_websites_string,
      :written_statement_optional,
    )
  end
end
