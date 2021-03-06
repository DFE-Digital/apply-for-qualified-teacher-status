class EligibilityInterface::QualificationForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :qualification

  validates :eligibility_check, presence: true
  validates :qualification, inclusion: { in: [true, false] }

  def qualification=(value)
    @qualification = ActiveModel::Type::Boolean.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.qualification = qualification
    eligibility_check.save!
  end
end
