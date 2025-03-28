# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestDeclineForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :further_information_request, :user
  validates :further_information_request, :user, presence: true

  attribute :note, :string
  validates :note, presence: true

  def save
    return false if invalid?

    ReviewRequestable.call(
      requestable: further_information_request,
      user:,
      passed: false,
      note:,
    )

    true
  end
end
