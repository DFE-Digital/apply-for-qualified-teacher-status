module SupportInterface
  class RegionsController < BaseController
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
      @region = Region.find(params[:id])

      # Non-legacy previews are more useful to the team.
      @region.legacy = false
    end

    private

    def region_params
      params.require(:region).permit(
        :legacy,
        :application_form_enabled,
        :sanction_check,
        :status_check,
        :teaching_authority_name,
        :teaching_authority_address,
        :teaching_authority_emails_string,
        :teaching_authority_websites_string,
        :teaching_authority_other
      )
    end
  end
end
