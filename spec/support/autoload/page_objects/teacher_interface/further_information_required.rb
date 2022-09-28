module PageObjects
  module TeacherInterface
    class FurtherInformationRequired < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{request_id}/items/{item_id}/edit"

      element :back_link, ".govuk-back-link"
      element :heading, ".govuk-heading-l"
      element :assessor_notes, ".govuk-inset-text"

      section :form, "form" do
        element :response_textarea, ".govuk-textarea"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
