# frozen_string_literal: true

class AssessorInterface::RequestableForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  def save
    return false if invalid?

    ReviewRequestable.call(
      requestable:,
      user:,
      passed:,
      failure_assessor_note: "",
    )

    true
  end

  delegate :application_form, :assessment, to: :requestable
end
