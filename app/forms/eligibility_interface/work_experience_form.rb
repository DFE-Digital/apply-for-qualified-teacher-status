# frozen_string_literal: true

class EligibilityInterface::WorkExperienceForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :work_experience, :string

  validates :eligibility_check, presence: true
  validates :work_experience,
            presence: true,
            inclusion: {
              in: EligibilityCheck.work_experiences.keys,
            }

  def save
    return false unless valid?

    eligibility_check.update!(work_experience:)
  end
end
