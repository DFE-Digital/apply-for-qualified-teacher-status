module PageObjects
  module TeacherInterface
    class RegistrationNumberForm < SitePrism::Page
      element :heading, "h1"
      element :input_number, ".govuk-input"

      section :details, ".govuk-details" do
        element :summary, ".govuk-details__summary"
        element :text, ".govuk-details__text"
      end
    end
  end
end
