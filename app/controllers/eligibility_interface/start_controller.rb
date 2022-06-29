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
    eligibility_check.save!
    redirect_to eligibility_interface_countries_path
  end
end
