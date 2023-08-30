# frozen_string_literal: true

class SupportInterface::RegionsController < SupportInterface::BaseController
  before_action :load_region

  def edit
  end

  def update
    if @region.update(region_params)
      flash[
        :success
      ] = "Successfully updated #{CountryName.from_region(@region)}"

      if params[:preview] == "preview"
        redirect_to preview_support_interface_region_path(@region)
      else
        redirect_to support_interface_countries_path
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def preview
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
