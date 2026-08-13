# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class EditRegion < SitePrism::Page
      set_url "/support/regions/{id}/edit"

      element :heading, "h1"
      element :sanction_check_field,
              "#support-interface-region-form-sanction-check-field"
      element :status_check_field,
              "#support-interface-region-form-status-check-field"
      element :other_information_field,
              "#support-interface-region-form-other-information-field"
      element :sanction_information_field,
              "#support-interface-region-form-sanction-information-field"
      element :status_information_field,
              "#support-interface-region-form-status-information-field"
      element :teaching_authority_address_field,
              "#support-interface-region-form-teaching-authority-address-field"
      element :teaching_authority_certificate_field,
              "#support-interface-region-form-teaching-authority-certificate-field"
      element :teaching_authority_emails_string_field,
              "#support-interface-region-form-teaching-authority-emails-string-field"
      element :teaching_authority_name_field,
              "#support-interface-region-form-teaching-authority-name-field"
      element :teaching_authority_online_checker_url_field,
              "#support-interface-region-form-teaching-authority-online-checker-url-field"
      element :teaching_authority_websites_string_field,
              "#support-interface-region-form-teaching-authority-websites-string-field"
      element :teaching_authority_requires_submission_email_true_field,
              "#support-interface-region-form-teaching-authority-requires-submission-email-true-field",
              visible: :all
      element :written_statement_optional_true_field,
              "#support-interface-region-form-written-statement-optional-true-field",
              visible: false
      element :requires_preliminary_check_true_field,
              "#support-interface-region-form-requires-preliminary-check-true-field",
              visible: false
      element :teaching_qualification_information_field,
              "#support-interface-region-form-teaching-qualification-information-field"

      element :preview_button, "button", text: "Preview"

      def has_heading?(text)
        heading.has_text?(text)
      end

      def select_sanction_check(text)
        sanction_check_field.select(text)
      end

      def select_status_check(text)
        status_check_field.select(text)
      end

      def fill_in_other_information(text)
        other_information_field.fill_in(with: text)
      end

      def fill_in_sanction_information(text)
        sanction_information_field.fill_in(with: text)
      end

      def fill_in_status_information(text)
        status_information_field.fill_in(with: text)
      end

      def fill_in_teaching_authority_address(text)
        teaching_authority_address_field.fill_in(with: text)
      end

      def fill_in_teaching_authority_certificate(text)
        teaching_authority_certificate_field.fill_in(with: text)
      end

      def fill_in_teaching_authority_emails(text)
        teaching_authority_emails_string_field.fill_in(with: text)
      end

      def fill_in_teaching_authority_name(text)
        teaching_authority_name_field.fill_in(with: text)
      end

      def fill_in_teaching_authority_online_checker_url(text)
        teaching_authority_online_checker_url_field.fill_in(with: text)
      end

      def fill_in_teaching_authority_websites(text)
        teaching_authority_websites_string_field.fill_in(with: text)
      end

      def select_yes_teaching_authority_requires_submission_email
        teaching_authority_requires_submission_email_true_field.choose(
          visible: :all,
        )
      end

      def check_written_statement_optional
        written_statement_optional_true_field.choose(visible: false)
      end

      def check_requires_preliminary_check
        requires_preliminary_check_true_field.choose(visible: false)
      end

      def fill_in_teaching_qualification_information(text)
        teaching_qualification_information_field.fill_in(with: text)
      end

      def click_preview
        preview_button.click
      end
    end
  end
end
