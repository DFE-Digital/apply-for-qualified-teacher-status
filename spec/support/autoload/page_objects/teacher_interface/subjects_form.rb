module PageObjects
  module TeacherInterface
    class SubjectsForm < SitePrism::Page
      element :heading, "h1"
      element :input_subject, ".govuk-input"
      element :continue_button, ".govuk-button:nth-of-type(1)"
      element :save_and_come_back, ".govuk-button:nth-of-type(1)"
    end
  end
end
