# frozen_string_literal: true

class SupportInterface::CountriesController < SupportInterface::BaseController
  before_action :load_country, except: :index
  before_action :load_edit_actions, only: %w[confirm_edit update]

  def index
    authorize [:support_interface, Country]
    @countries = Country.includes(:regions).order(:code)
  end

  def edit
    @all_regions = @country.regions.map(&:name).join("\n")
  end

  def confirm_edit
    @country.assign_attributes(country_params)
  end

  def update
    if @country.update(country_params)
      @diff_actions.each do |action|
        case action[:action]
        when :create
          @country.regions.create!(name: action[:name])
        when :delete
          region = @country.regions.find_by!(name: action[:name])
          region.eligibility_checks.delete_all
          region.destroy!
        end
      end

      flash[
        :success
      ] = "Successfully updated #{CountryName.from_country(@country)}"

      redirect_to support_interface_countries_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_country
    @country = Country.includes(:regions).find(params[:id])
    authorize [:support_interface, @country]
  end

  def load_edit_actions
    @all_regions = (params.dig(:country, :all_regions) || "").chomp
    @diff_actions = calculate_diff_actions
  end

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
    params.require(:country).permit(
      :eligibility_enabled,
      :eligibility_skip_questions,
      :qualifications_information,
      :requires_preliminary_check,
      :teaching_authority_name,
      :teaching_authority_address,
      :teaching_authority_emails_string,
      :teaching_authority_websites_string,
      :teaching_authority_certificate,
      :teaching_authority_other,
      :teaching_authority_sanction_information,
      :teaching_authority_status_information,
      :teaching_authority_online_checker_url,
    )
  end
end
