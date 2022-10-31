class EligibilityInterface::CompletedRequirementsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :completed_requirements, :boolean

  validates :eligibility_check, presence: true
  validates :completed_requirements, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(completed_requirements:)
  end
end
