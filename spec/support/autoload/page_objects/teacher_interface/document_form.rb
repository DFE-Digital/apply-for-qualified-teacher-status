module PageObjects
  module TeacherInterface
    class DocumentForm < SitePrism::Page
      set_url "/teacher/application/documents/{document_id}/edit"

      element :heading, "h1"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :continue_button, "button"
      end
    end
  end
end
