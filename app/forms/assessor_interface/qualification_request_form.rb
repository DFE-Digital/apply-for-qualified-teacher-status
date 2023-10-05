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

  attribute :note, :string
  validates :note, presence: true, if: -> { received && passed == false }

  attribute :failed, :boolean
  validates :failed, inclusion: [true, false], unless: :received

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      if received && !requestable.received?
        ReceiveRequestable.call(requestable:, user:)
      elsif !received && requestable.received?
        revert_receive_requestable
      end

      if review_passed.nil?
        requestable.update!(review_passed: nil, reviewed_at: nil)
        ApplicationFormStatusUpdater.call(application_form:, user:)
      else
        ReviewRequestable.call(
          requestable:,
          user:,
          passed: review_passed,
          note:,
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
