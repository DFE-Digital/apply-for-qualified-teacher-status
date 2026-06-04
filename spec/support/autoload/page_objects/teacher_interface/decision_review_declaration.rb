# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DecisionReviewDeclaration < SitePrism::Page
      set_url "/teacher/application/decision-review-requests/declaration"

      section :form, "form" do
        element :confirm, ".govuk-checkboxes__input", visible: false
        element :submit_button, ".govuk-button"
      end
    end
  end
end
