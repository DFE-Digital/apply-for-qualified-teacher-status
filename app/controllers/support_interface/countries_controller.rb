# frozen_string_literal: true

module SupportInterface
  class CountriesController < BaseController
    def index
      authorize [:support_interface, Country]
      @countries = Country.includes(:regions).order(:code)
    end

    def edit
      @form =
        CountryForm.new(
          country:,
          eligibility_enabled: country.eligibility_enabled,
          eligibility_skip_questions: country.eligibility_skip_questions,
          has_regions: country.regions.count > 1,
          qualifications_information: country.qualifications_information,
          region_names: country.regions.pluck(:name).join("\n"),
          requires_preliminary_check: country.requires_preliminary_check,
          teaching_authority_address: country.teaching_authority_address,
          teaching_authority_certificate:
            country.teaching_authority_certificate,
          teaching_authority_emails_string:
            country.teaching_authority_emails_string,
          teaching_authority_name: country.teaching_authority_name,
          teaching_authority_online_checker_url:
            country.teaching_authority_online_checker_url,
          teaching_authority_other: country.teaching_authority_other,
          teaching_authority_sanction_information:
            country.teaching_authority_sanction_information,
          teaching_authority_status_information:
            country.teaching_authority_status_information,
          teaching_authority_websites_string:
            country.teaching_authority_websites_string,
        )
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
        begin
          country = Country.includes(:regions).find(params[:id])
          authorize [:support_interface, country]
          country
        end
    end

    def country_params
      params.require(:support_interface_country_form).permit(
        :has_regions,
        :region_names,
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
end
