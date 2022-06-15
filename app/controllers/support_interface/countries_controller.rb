module SupportInterface
  class CountriesController < BaseController
    def index
    end

    def configure_private_beta
      ConfigureCountries.private_beta!

      flash[:success] = "Private beta countries configured"
      redirect_to support_interface_countries_path
    end
  end
end
