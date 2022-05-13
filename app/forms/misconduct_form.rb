class MisconductForm
  include ActiveModel::Model

  attr_accessor :eligibility_check, :free_of_sanctions

  validates :eligibility_check, presence: true
  validates :free_of_sanctions, presence: true, inclusion: { in: %w[true false], if: :free_of_sanctions? }

  def free_of_sanctions?
    !free_of_sanctions.blank?
  end

  def save
    return false unless valid?

    eligibility_check.free_of_sanctions = free_of_sanctions
    eligibility_check.save
  end
end
