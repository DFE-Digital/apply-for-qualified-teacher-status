class EligibilityInterface::CompletedRequirementsForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :completed_requirements

  validates :eligibility_check, presence: true
  validates :completed_requirements, inclusion: { in: [true, false] }

  def completed_requirements=(value)
    @completed_requirements = ActiveModel::Type::Boolean.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.completed_requirements = completed_requirements
    eligibility_check.save!
  end

  def success_url
    Rails.application.routes.url_helpers.eligibility_interface_degree_path
  end
end
