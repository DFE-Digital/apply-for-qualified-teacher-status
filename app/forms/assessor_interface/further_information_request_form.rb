# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :further_information_request, :user
  validates :further_information_request, :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  attribute :failure_reason, :string
  validates :failure_reason, presence: true, if: -> { passed == false }

  def save
    return false unless valid?

    UpdateFurtherInformationRequest.call(
      further_information_request:,
      user:,
      params: {
        passed:,
        failure_reason:,
      },
    )

    true
  end
end
