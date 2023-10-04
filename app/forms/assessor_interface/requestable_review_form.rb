# frozen_string_literal: true

class AssessorInterface::RequestableReviewForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  attribute :note, :string
  validates :note, presence: true, if: -> { passed == false }

  def save
    return false if invalid?

    ReviewRequestable.call(requestable:, user:, passed:, note:)

    true
  end
end
