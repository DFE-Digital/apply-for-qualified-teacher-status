# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class AddAnotherWorkHistory < SitePrism::Page
      set_url "/teacher/application/work_histories/add_another"

      element :heading, "h1"

      section :form, "form" do
        section :true_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :false_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
