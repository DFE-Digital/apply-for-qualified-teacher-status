module PageObjects
  module TeacherInterface
    class CreateOrSignIn < SitePrism::Page
      set_url "/teacher/create_or_sign_in"

      element :heading, "h1"

      section :form, "form" do
        sections :radio_items,
                 PageObjects::GovukRadioItem,
                 ".govuk-radios__item"
        element :email_input, ".govuk-input"
        element :continue_button, ".govuk-button"
      end

      load_validation { has_heading? && has_form? }

      def submit_sign_in(email:)
        form.radio_items.first.choose
        form.email_input.fill_in with: email
        form.continue_button.click
      end

      def submit_create
        form.radio_items.second.choose
        form.continue_button.click
      end
    end
  end
end
