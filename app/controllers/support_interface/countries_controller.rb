class SupportInterface::CountriesController < SupportInterface::BaseController
  def index
    @countries = Country.includes(:regions)
  end

  def edit
    @country = Country.includes(:regions).find(params[:id])
    @all_regions = @country.regions.map(&:name).join("\n")
  end

  def confirm_edit
    @country = Country.includes(:regions).find(params[:id])
    @all_regions = (params.dig(:country, :all_regions) || "").chomp
    @diff_actions = calculate_diff_actions

    if @diff_actions.empty?
      redirect_to edit_support_interface_country_path(@country)
    end
  end

  private

  def calculate_diff_actions
    current_region_names = @country.regions.map(&:name)
    new_region_names = @all_regions.split("\n").map(&:chomp)
    new_region_names = [""] if new_region_names.empty?

    regions_to_delete = current_region_names - new_region_names
    regions_to_create = new_region_names - current_region_names

    delete_actions = regions_to_delete.map { |name| { action: :delete, name: } }
    create_actions = regions_to_create.map { |name| { action: :create, name: } }

    (delete_actions + create_actions).sort_by { |action| action[:name] }
  end

  def country_params
    params.require(:country).permit(:all_regions)
  end
end
