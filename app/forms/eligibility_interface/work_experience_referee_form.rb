# frozen_string_literal: true

class EligibilityInterface::WorkExperienceRefereeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :work_experience_referee, :boolean

  validates :eligibility_check, presence: true
  validates :work_experience_referee, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(work_experience_referee:)
  end
end
