class SupportInterface::CountriesController < SupportInterface::BaseController
  def index
    @countries = Country.includes(:regions)
  end

  def edit
    @country = Country.includes(:regions).find(params[:id])
    @all_regions = @country.regions.map(&:name).join("\n")
  end
end
