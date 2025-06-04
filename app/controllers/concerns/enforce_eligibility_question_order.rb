# frozen_string_literal: true

module EnforceEligibilityQuestionOrder
  extend ActiveSupport::Concern

  included { before_action :redirect_by_status }

  def redirect_by_status
    return if current_page_is_allowed?

    expected_path = paths[eligibility_check.status(includes_prioritisation:)]
    redirect_to(expected_path) if expected_path && expected_path != request.path
  end

  private

  def current_page_is_allowed?
    order = paths.keys.index(eligibility_check.status(includes_prioritisation:))
    current_position = paths.values.index(request.path)
    current_position && order && current_position <= order
  end

  def paths
    {
      country: eligibility_interface_countries_path,
      region: eligibility_interface_region_path,
      qualification: eligibility_interface_qualifications_path,
      degree: eligibility_interface_degree_path,
      work_experience: eligibility_interface_work_experience_path,
      misconduct: eligibility_interface_misconduct_path,
      work_experience_in_england:
        eligibility_interface_work_experience_in_england_path,
      teach_children: eligibility_interface_teach_children_path,
      qualified_for_subject: eligibility_interface_qualified_for_subject_path,
      result: eligibility_interface_result_path,
    }.slice(*eligibility_check.status_route(includes_prioritisation:))
  end

  def includes_prioritisation
    FeatureFlags::FeatureFlag.active?(:prioritisation)
  end
end
