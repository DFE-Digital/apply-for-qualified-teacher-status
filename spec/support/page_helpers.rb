module PageHelpers
  def application_page
    @application_page ||= PageObjects::AssessorInterface::Application.new
  end

  def applications_page
    @applications_page ||= PageObjects::AssessorInterface::Applications.new
  end

  def assign_assessor_page
    @assign_assessor_page ||= PageObjects::AssessorInterface::AssignAssessor.new
  end

  def assign_reviewer_page
    @assign_reviewer_page ||= PageObjects::AssessorInterface::AssignReviewer.new
  end

  def check_personal_information_page
    @check_personal_information_page ||=
      PageObjects::AssessorInterface::CheckPersonalInformation.new
  end

  def check_professional_standing_page
    @check_professional_standing_page ||=
      PageObjects::AssessorInterface::CheckProfessionalStanding.new
  end

  def check_qualifications_page
    @check_qualifications_page ||=
      PageObjects::AssessorInterface::CheckQualifications.new
  end

  def check_work_history_page
    @check_work_history_page ||=
      PageObjects::AssessorInterface::CheckWorkHistory.new
  end

  def complete_assessment_page
    @complete_assessment_page ||=
      PageObjects::AssessorInterface::CompleteAssessment.new
  end

  def country_page
    @country_page ||= PageObjects::EligibilityInterface::Country.new
  end

  def degree_page
    @degree_page ||= PageObjects::EligibilityInterface::Degree.new
  end

  def eligible_page
    @eligible_page = PageObjects::EligibilityInterface::Eligible.new
  end

  def ineligible_page
    @ineligible_page = PageObjects::EligibilityInterface::Ineligible.new
  end

  def login_page
    @login_page ||= PageObjects::AssessorInterface::Login.new
  end

  def misconduct_page
    @misconduct_page ||= PageObjects::EligibilityInterface::Misconduct.new
  end

  def performance_page
    @performance_page ||= PageObjects::Performance.new
  end

  def personas_page
    @personas_page ||= PageObjects::Personas.new
  end

  def qualification_page
    @qualification_page ||= PageObjects::EligibilityInterface::Qualification.new
  end

  def region_page
    @region_page ||= PageObjects::EligibilityInterface::Region.new
  end

  def start_page
    @start_page ||= PageObjects::EligibilityInterface::Start.new
  end

  def teach_children_page
    @teach_children_page ||=
      PageObjects::EligibilityInterface::TeachChildren.new
  end

  def timeline_page
    @timeline_page ||= PageObjects::AssessorInterface::Timeline.new
  end

  def then_i_see_the(page, **args)
    expect(send(page.to_sym)).to be_displayed(**args)
  end

  def when_i_visit_the(page, **args)
    send(page.to_sym).load(**args)
  end
end
