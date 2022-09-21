class EligibilityInterface::StartController < EligibilityInterface::BaseController
  def root
    redirect_to eligibility_interface_start_url
  end

  def show
  end

  def create
    @eligibility_check = EligibilityCheck.new if eligibility_check.completed_at?
    eligibility_check.save!

    if FeatureFlag.active?(:teacher_applications)
      redirect_to :create_or_new_teacher_session
    else
      redirect_to :eligibility_interface_countries
    end
  end
end
