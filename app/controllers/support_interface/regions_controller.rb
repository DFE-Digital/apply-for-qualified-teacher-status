module SupportInterface
  class RegionsController < BaseController
    def edit
      @region = Region.find(params[:id])
    end

    def update
      @region = Region.find(params[:id])

      if @region.update(region_params)
        redirect_to support_interface_countries_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def region_params
      params.require(:region).permit(
        :legacy,
        :sanction_check,
        :status_check,
        :teaching_authority_address,
        :teaching_authority_certificate,
        :teaching_authority_email_address,
        :teaching_authority_website
      )
    end
  end
end
