# frozen_string_literal: true

class AssessorInterface::RequestableVerifyPassedForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  def save
    return false if invalid?

    ReceiveRequestable.call(requestable:, user:) unless requestable.received?

    VerifyRequestable.call(requestable:, user:, passed:, note: "") if passed

    true
  end
end
