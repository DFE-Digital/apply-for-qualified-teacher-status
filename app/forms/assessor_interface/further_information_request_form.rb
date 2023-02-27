# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :further_information_request, :user
  validates :further_information_request, :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  attribute :failure_assessor_note, :string
  validates :failure_assessor_note, presence: true, if: -> { passed == false }

  def save
    return false unless valid?

    ReviewRequestable.call(
      requestable: further_information_request,
      user:,
      passed:,
      failure_assessor_note:,
    )

    true
  end
end
