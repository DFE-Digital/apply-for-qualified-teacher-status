class EligibilityInterface::StartController < EligibilityInterface::BaseController
  def root
    if FeatureFlag.active?(:service_start)
      redirect_to eligibility_interface_start_url
    else
      redirect_to MUTUAL_RECOGNITION_URL, allow_other_host: true
    end
  end

  def show
  end

  def create
    @eligibility_check = EligibilityCheck.new if eligibility_check.completed_at?
    eligibility_check.save!

    if FeatureFlag.active?(:teacher_applications)
      redirect_to :new_teacher_session
    else
      redirect_to :eligibility_interface_countries
    end
  end
end
