# frozen_string_literal: true

module TeacherInterface
  class CreateDecisionReviewRequestForm < BaseForm
    attr_accessor :application_form, :decision_review_request

    attribute :comment, :string
    attribute :has_supporting_documents, :boolean

    validates :application_form, presence: true
    validates :comment, presence: true
    validates :has_supporting_documents, inclusion: [true, false]

    def update_model
      self.decision_review_request =
        application_form.assessment.create_decision_review_request!(
          comment:,
          has_supporting_documents:,
        )
    end
  end
end
