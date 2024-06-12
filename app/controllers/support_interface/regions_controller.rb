# frozen_string_literal: true

module SupportInterface
  class RegionsController < BaseController
    def edit
      @form = RegionForm.for_existing_region(region)
    end

    def update
      @form = RegionForm.new(region_params.merge(region:))
      if @form.invalid?
        render :edit, status: :unprocessable_entity
      elsif ActiveModel::Type::Boolean.new.cast(params[:preview])
        session[:region] = region_params
        redirect_to [:preview, :support_interface, region]
      else
        @form.save!
        redirect_to %i[support_interface countries]
      end
    end

    def preview
      @form = RegionForm.new(session[:region].merge(region:))
      @form.assign_region_attributes
    end

    private

    def region
      @region ||= authorize [:support_interface, Region.find(params[:id])]
    end

    def region_params
      params.require(:support_interface_region_form).permit(
        :all_sections_necessary,
        :other_information,
        :requires_preliminary_check,
        :sanction_check,
        :sanction_information,
        :status_check,
        :status_information,
        :teaching_authority_address,
        :teaching_authority_certificate,
        :teaching_authority_emails_string,
        :teaching_authority_name,
        :teaching_authority_online_checker_url,
        :teaching_authority_provides_written_statement,
        :teaching_authority_requires_submission_email,
        :teaching_authority_websites_string,
        :teaching_qualification_information,
        :work_history_section_to_omit,
        :written_statement_optional,
      )
    end
  end
end
