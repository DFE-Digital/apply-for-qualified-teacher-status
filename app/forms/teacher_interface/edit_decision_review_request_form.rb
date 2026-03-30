# frozen_string_literal: true

module TeacherInterface
  class EditDecisionReviewRequestForm < BaseForm
    attr_accessor :application_form, :decision_review_request

    attribute :comment, :string
    attribute :has_supporting_documents, :boolean

    validates :application_form, presence: true
    validates :decision_review_request, presence: true
    validates :comment, presence: true
    validates :has_supporting_documents, inclusion: [true, false]

    def update_model
      decision_review_request.update!(comment:, has_supporting_documents:)
    end
  end
end
