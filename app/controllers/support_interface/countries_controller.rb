# frozen_string_literal: true

module SupportInterface
  class CountriesController < BaseController
    def index
      authorize [:support_interface, Country]

      @countries =
        Country
          .includes(:regions)
          .sort_by { |country| CountryName.from_country(country) }

      render layout: "full_from_desktop"
    end

    def edit
      @form = CountryForm.for_existing_country(country)
    end

    def update
      @form = CountryForm.new(country_params.merge(country:))
      if @form.invalid?
        render :edit, status: :unprocessable_entity
      elsif ActiveModel::Type::Boolean.new.cast(params[:preview])
        session[:country] = country_params
        redirect_to [:preview, :support_interface, country]
      else
        @form.save!
        redirect_to %i[support_interface countries]
      end
    end

    def preview
      @form = CountryForm.new(session[:country].merge(country:))
      @form.assign_country_attributes
    end

    private

    def country
      @country ||=
        authorize [
                    :support_interface,
                    Country.includes(:regions).find(params[:id]),
                  ]
    end

    def country_params
      params.require(:support_interface_country_form).permit(
        :eligibility_enabled,
        :eligibility_route,
        :has_regions,
        :other_information,
        :region_names,
        :sanction_information,
        :status_information,
        :teaching_qualification_information,
      )
    end
  end
end
