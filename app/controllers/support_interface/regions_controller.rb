# frozen_string_literal: true

class SupportInterface::RegionsController < SupportInterface::BaseController
  skip_before_action :authorize_support, only: :preview

  def edit
    @region = Region.find(params[:id])
  end

  def update
    @region = Region.find(params[:id])

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
    authorize :support, :show?

    @region = Region.find(params[:id])

    # Non-legacy previews are more useful to the team.
    @region.legacy = false
  end

  private

  def region_params
    params.require(:region).permit(
      :legacy,
      :application_form_enabled,
      :application_form_skip_work_history,
      :reduced_evidence_accepted,
      :qualifications_information,
      :sanction_check,
      :status_check,
      :teaching_authority_name,
      :teaching_authority_address,
      :teaching_authority_emails_string,
      :teaching_authority_websites_string,
      :teaching_authority_certificate,
      :teaching_authority_sanction_information,
      :teaching_authority_status_information,
      :teaching_authority_other,
      :teaching_authority_online_checker_url,
      :teaching_authority_provides_written_statement,
      :teaching_authority_requires_submission_email,
    )
  end
end
