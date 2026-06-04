# frozen_string_literal: true

module TeacherInterface
  class EditDecisionReviewRequestForm < BaseForm
    attr_accessor :decision_review_request

    attribute :comment, :string
    attribute :has_supporting_documents, :boolean

    validates :decision_review_request, presence: true
    validates :comment, presence: true, max_text_length: true
    validates :has_supporting_documents, inclusion: [true, false]

    def update_model
      decision_review_request.update!(comment:, has_supporting_documents:)
    end
  end
end
