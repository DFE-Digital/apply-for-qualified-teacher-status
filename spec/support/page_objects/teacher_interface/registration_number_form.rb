module PageObjects
  module TeacherInterface
    class RegistrationNumberForm < SitePrism::Page
      element :heading, "h1"
      element :input_number, ".govuk-input"
    end
  end
end
