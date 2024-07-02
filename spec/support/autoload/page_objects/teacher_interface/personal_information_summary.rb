# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class PersonalInformationSummary < SitePrism::Page
      set_url "/teacher/application/personal_information/check"

      element :heading, "h1"
      element :summary_card, ".govuk-summary-list"
    end
  end
end
