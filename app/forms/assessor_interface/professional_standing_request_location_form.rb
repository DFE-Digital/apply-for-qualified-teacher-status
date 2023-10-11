# frozen_string_literal: true

class AssessorInterface::ProfessionalStandingRequestLocationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :received, :boolean
  validates :received, inclusion: [true, false]

  attribute :location_note, :string

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      if received && !requestable.received?
        ReceiveRequestable.call(requestable:, user:)
      elsif !received && requestable.received?
        revert_receive_requestable
      end

      if requestable.requested? && requestable.reviewed?
        requestable.update!(review_passed: nil, reviewed_at: nil)
        ApplicationFormStatusUpdater.call(application_form:, user:)
      end

      requestable.update!(location_note: location_note.presence || "")
    end

    true
  end

  private

  delegate :application_form, to: :requestable

  def revert_receive_requestable
    requestable.requested!
    TimelineEvent.requestable_received.where(requestable:).destroy_all
    ApplicationFormStatusUpdater.call(application_form:, user:)
  end
end
