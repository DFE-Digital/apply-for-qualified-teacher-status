module PageObjects
  module TeacherInterface
    class CheckFurtherInformationRequestAnswers < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{request_id}/edit"

      element :heading, ".govuk-heading-xl"
    end
  end
end
