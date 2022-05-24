class RecognisedForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :recognised

  validates :eligibility_check, presence: true
  validates :recognised, inclusion: { in: [true, false] }

  def recognised=(value)
    @recognised = ActiveModel::Type::Boolean.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.recognised = recognised
    eligibility_check.save!
  end
end
