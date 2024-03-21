# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ConsentQualificationRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/consent-method"

      section :form, "form" do
        sections :items, PageObjects::GovukRadioItem, ".govuk-radios__item"
        element :submit_button, ".govuk-button"
      end

      def submit_signed_institution
        form.items.first.choose
        form.submit_button.click
      end

      def submit_signed_ecctis
        form.items.second.choose
        form.submit_button.click
      end

      def submit_unsigned
        form.items.third.choose
        form.submit_button.click
      end
    end
  end
end
