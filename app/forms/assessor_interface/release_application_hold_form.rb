# frozen_string_literal: true

class AssessorInterface::ReleaseApplicationHoldForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_hold, :user
  attribute :release_comment, :string

  validates :application_hold, :user, :release_comment, presence: true

  validate :application_hold_not_already_released

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      application_hold.update!(released_at: Time.current, release_comment:)
    end
  end

  def application_hold_not_already_released
    if application_hold&.released_at.present?
      errors.add(:application_hold, :invalid)
    end
  end
end
