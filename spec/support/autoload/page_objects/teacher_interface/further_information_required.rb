module PageObjects
  module TeacherInterface
    class FurtherInformationRequired < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{request_id}/items/{item_id}/edit"

      element :back_link, ".govuk-back-link"
      element :heading, ".govuk-heading-l"
      element :assessor_notes, ".govuk-inset-text"
    end
  end
end
