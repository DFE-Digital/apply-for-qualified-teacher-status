# frozen_string_literal: true

class AssessorInterface::RequestableReviewForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :reviewed, :boolean
  validates :reviewed, inclusion: [true, false], if: :validate_reviewed?

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false], if: :validate_passed?

  attribute :failure_assessor_note, :string
  validates :failure_assessor_note,
            presence: true,
            if: :validate_failure_assessor_note?

  def save
    return false if invalid?

    self.passed = nil if reviewed == false

    ReviewRequestable.call(requestable:, user:, passed:, failure_assessor_note:)

    true
  end

  private

  def validate_reviewed?
    requestable.is_a?(Locatable)
  end

  def validate_passed?
    validate_reviewed? ? reviewed == true : true
  end

  def validate_failure_assessor_note?
    validate_passed? && passed == false
  end
end
