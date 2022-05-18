class QualificationForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :qualification

  validates :eligibility_check, presence: true

  def qualification=(value)
    @qualification = ActiveMode::Type.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.qualification = qualification
    eligibility_check.save!
  end

  def success_url
    ApplicationController
      .routes
      .url_helpers
      .teacher_interface_qualifications_path
  end
end
