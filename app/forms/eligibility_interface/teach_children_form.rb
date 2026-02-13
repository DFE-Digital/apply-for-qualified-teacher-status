# frozen_string_literal: true

class EligibilityInterface::TeachChildrenForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :teach_children, :boolean

  validates :eligibility_check, presence: true
  validate :teach_children_inclusion_with_age_range

  def save
    return false unless valid?

    eligibility_check.update!(teach_children:)
  end

  private

  def teach_children_inclusion_with_age_range
    unless [true, false].include?(teach_children)
      age_range =
        (
          if eligibility_check.qualified_for_subject_required? &&
               !eligibility_check.eligible_work_experience_in_england?
            "11 and 16"
          else
            "5 and 16"
          end
        )
      errors.add(:teach_children, :inclusion, age_range: age_range)
    end
  end
end
