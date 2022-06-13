class EligibilityInterface::DegreeForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :degree

  validates :eligibility_check, presence: true
  validates :degree, inclusion: { in: [true, false] }

  def degree=(value)
    @degree = ActiveModel::Type::Boolean.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.degree = degree
    eligibility_check.save!
  end

  def success_url
    Rails
      .application
      .routes
      .url_helpers
      .eligibility_interface_qualifications_path
  end
end
