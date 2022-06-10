class MisconductForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :free_of_sanctions

  validates :eligibility_check, presence: true
  validates :free_of_sanctions, inclusion: { in: [true, false] }

  def free_of_sanctions=(value)
    boolean = ActiveModel::Type::Boolean.new
    @free_of_sanctions = boolean.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.free_of_sanctions = free_of_sanctions
    eligibility_check.save!
  end

  def success_url
    if eligibility_check.eligible?
      Rails.application.routes.url_helpers.eligibility_interface_eligible_path
    else
      Rails.application.routes.url_helpers.eligibility_interface_ineligible_path
    end
  end
end
