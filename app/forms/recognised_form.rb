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

  def eligible?
    eligibility_check.recognised
  end

  def success_url
    unless eligible?
      return(
        Rails.application.routes.url_helpers.teacher_interface_ineligible_path
      )
    end

    Rails.application.routes.url_helpers.teacher_interface_misconduct_path
  end
end
