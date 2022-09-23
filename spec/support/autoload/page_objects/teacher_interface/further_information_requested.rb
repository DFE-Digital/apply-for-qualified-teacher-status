module PageObjects
  module TeacherInterface
    class FurtherInformationRequested < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{further_information_request_id}"

      element :heading, ".govuk-heading-l"
    end
  end
end
