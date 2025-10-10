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

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      ApplicationHold.create!(
        application_form:,
        reason:,
        reason_comment:,
      )
    end
  end
end
