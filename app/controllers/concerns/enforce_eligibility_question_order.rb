module EnforceEligibilityQuestionOrder
  extend ActiveSupport::Concern

  included { before_action :redirect_by_status }

  def redirect_by_status
    return if current_page_is_allowed?

    expected_path = paths[eligibility_check.status]
    redirect_to(expected_path) if expected_path && expected_path != request.path
  end

  private

  def current_page_is_allowed?
    order = paths.keys.index(eligibility_check&.status)
    current_position = paths.values.index(request.path)
    current_position && order && current_position <= order
  end

  def paths
    {
      country: eligibility_interface_countries_path,
      region: eligibility_interface_region_path,
      completed_requirements: eligibility_interface_completed_requirements_path,
      qualification: eligibility_interface_qualifications_path,
      degree: eligibility_interface_degree_path,
      teach_children: eligibility_interface_teach_children_path,
      misconduct: eligibility_interface_misconduct_path
    }
  end
end
