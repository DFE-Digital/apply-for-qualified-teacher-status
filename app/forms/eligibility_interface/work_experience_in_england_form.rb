# frozen_string_literal: true

class EligibilityInterface::WorkExperienceInEnglandForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :eligible, :boolean

  validates :eligibility_check, presence: true
  validates :eligible, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(eligible_work_experience_in_england: eligible)
  end
end
