# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditTeachingQualification < SitePrism::Page
      set_url "/assessor/applications/{reference}/qualifications/{qualification_id}/edit"

      section :form, "form" do
        element :title_field,
                "#assessor-interface-qualification-update-form-title-field"
        element :institution_name_field,
                "#assessor-interface-qualification-update-form-institution-name-field"

        element :start_date_month_field,
                "#assessor_interface_qualification_update_form_start_date_2i"
        element :start_date_year_field,
                "#assessor_interface_qualification_update_form_start_date_1i"
        element :complete_date_month_field,
                "#assessor_interface_qualification_update_form_complete_date_2i"
        element :complete_date_year_field,
                "#assessor_interface_qualification_update_form_complete_date_1i"
        element :certificate_date_month_field,
                "#assessor_interface_qualification_update_form_certificate_date_2i"
        element :certificate_date_year_field,
                "#assessor_interface_qualification_update_form_certificate_date_1i"

        element :true_part_of_degree_radio_item,
                "#assessor-interface-qualification-update-form-" \
                  "teaching-qualification-part-of-degree-true-field",
                visible: false
        element :false_part_of_degree_radio_item,
                "#assessor-interface-qualification-update-form-" \
                  "teaching-qualification-part-of-degree-false-field",
                visible: false

        element :submit_button, ".govuk-button"
      end
    end
  end
end
