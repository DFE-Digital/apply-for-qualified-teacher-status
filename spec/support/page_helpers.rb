require "support/page_objects/govuk_radio_item"
require "support/page_objects/govuk_checkbox_item"
require "support/page_objects/page_header"

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

  def check_qualifications_page
    @check_qualifications_page ||=
      PageObjects::AssessorInterface::CheckQualifications.new
  end

  def login_page
    @login_page ||= PageObjects::AssessorInterface::Login.new
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
