# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DecisionReviewNew < SitePrism::Page
      set_url "/teacher/application/decision-review-requests/new"

      section :form, "form" do
        element :comment_field,
                "#teacher-interface-create-decision-review-request-form-comment-field"

        element :has_supporting_documents_true_field,
                "#teacher-interface-create-decision-review-request-form-has-supporting-documents-true-field",
                visible: false
        element :has_supporting_documents_false_field,
                "#teacher-interface-create-decision-review-request-form-has-supporting-documents-field",
                visible: false
      end
    end
  end
end
