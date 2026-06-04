# frozen_string_literal: true

class AssessorInterface::DecisionReviewRequestReviewForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :decision_review_request
  validates :decision_review_request, presence: true

  attribute :review_passed, :boolean
  validates :review_passed, inclusion: [true, false]

  attribute :review_failed_note, :string
  attribute :review_passed_note, :string

  validates :review_failed_note,
            presence: true,
            if: -> { review_passed == false }
  validates :review_passed_note,
            presence: true,
            if: -> { review_passed == true }

  def save
    return false if invalid?

    review_note = review_passed ? review_passed_note : review_failed_note

    decision_review_request.update!(review_passed:, review_note:)
  end
end
