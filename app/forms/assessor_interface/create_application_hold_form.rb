# frozen_string_literal: true

class AssessorInterface::CreateApplicationHoldForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :user
  attribute :reason, :string
  attribute :reason_comment, :string

  validates :reason, :user, :application_form, presence: true
  validates :reason_comment, presence: true, if: -> { reason == "other" }

  validate :application_form_not_already_on_hold

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      application_hold =
        ApplicationHold.create!(application_form:, reason:, reason_comment:)

      TimelineEvent.create!(
        application_form:,
        application_hold:,
        event_type: "application_put_on_hold",
        creator: user,
      )
    end
  end

  private

  def application_form_not_already_on_hold
    errors.add(:application_form, :invalid) if application_form&.on_hold?
  end
end
