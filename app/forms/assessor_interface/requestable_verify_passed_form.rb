# frozen_string_literal: true

class AssessorInterface::RequestableVerifyPassedForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  attribute :received, :boolean
  validates :received, inclusion: [nil, true, false]

  def save
    return false if invalid?

    if (passed || received) && !requestable.received?
      ReceiveRequestable.call(requestable:, user:)
    elsif received == false && requestable.received?
      UnreceiveRequestable.call(requestable:, user:)
    end

    VerifyRequestable.call(requestable:, user:, passed:, note: "") if passed

    true
  end
end
