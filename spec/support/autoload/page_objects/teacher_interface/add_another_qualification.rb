module PageObjects
  module TeacherInterface
    class AddAnotherQualification < SitePrism::Page
      set_url "/teacher/application/qualifications/add_another"

      element :heading, "h1"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
