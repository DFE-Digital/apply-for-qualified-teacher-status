# frozen_string_literal: true

class AssessorInterface::SelectQualificationsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form, :session
  validates :application_form, presence: true
  validates :session, exclusion: [nil]

  attribute :qualification_ids
  validates :qualification_ids,
            presence: true,
            inclusion: {
              in: ->(form) do
                form
                  .application_form
                  &.qualifications
                  &.pluck(:id)
                  &.map(&:to_s) || []
              end,
            }

  def save
    return false unless valid?
    session[:qualification_ids] = qualification_ids
    true
  end
end
