# frozen_string_literal: true

class AssessorInterface::DecisionReviewRequestReviewForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :decision_review_request
  validates :decision_review_request, presence: true

  attribute :review_passed, :boolean
  validates :review_passed, inclusion: [true, false]

  attribute :review_note, :string
  validates :review_note, presence: true, if: -> { review_passed == false }

  def save
    return false if invalid?

    decision_review_request.update!(review_passed:, review_note:)
  end
end
