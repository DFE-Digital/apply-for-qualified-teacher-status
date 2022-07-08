class EligibilityInterface::MisconductForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :misconduct

  validates :eligibility_check, presence: true
  validates :misconduct, inclusion: { in: [true, false] }

  def misconduct=(value)
    @misconduct = ActiveModel::Type::Boolean.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.free_of_sanctions = !misconduct
    eligibility_check.save!
  end
end
