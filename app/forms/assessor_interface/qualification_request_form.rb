# frozen_string_literal: true

class AssessorInterface::QualificationRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :received, :boolean
  validates :received, inclusion: [true, false]

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false], if: :received

  attribute :failure_assessor_note, :string
  validates :failure_assessor_note,
            presence: true,
            if: -> { received && passed == false }

  attribute :failed, :boolean
  validates :failed, inclusion: [true, false], unless: :received

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      if received && !requestable.received?
        ReceiveRequestable.call(requestable:, user:)
      end

      if !received && !requestable.expired?
        ExpireRequestable.call(requestable:, user:)
      end

      unless review_passed.nil?
        ReviewRequestable.call(
          requestable:,
          user:,
          passed: review_passed,
          failure_assessor_note:,
        )
      end
    end

    true
  end

  delegate :application_form, :assessment, to: :requestable

  private

  def review_passed
    if received
      passed
    else
      failed ? false : nil
    end
  end

  def revert_receive_requestable
    requestable.requested!
    TimelineEvent.requestable_received.where(requestable:).destroy_all
    ApplicationFormStatusUpdater.call(application_form:, user:)
  end
end
