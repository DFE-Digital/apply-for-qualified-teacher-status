module SystemHelpers
  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_service_is_closed
    FeatureFlag.deactivate(:service_open)
  end

  def given_the_service_is_startable
    FeatureFlag.activate(:service_start)
  end

  def given_an_eligible_eligibility_check
    create(:country, :with_national_region, code: "GB-SCT")
    visit "/eligibility/start"
    click_button "Start now"
    fill_in "eligibility-interface-country-form-location-field",
            with: "Scotland"
    click_button "Continue", visible: false
    choose "Yes", visible: false
    click_button "Continue", visible: false
    choose "Yes", visible: false
    click_button "Continue", visible: false
    choose "Yes", visible: false
    click_button "Continue", visible: false
    choose "No", visible: false
    click_button "Continue", visible: false
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV.fetch("SUPPORT_USERNAME", "test"),
      ENV.fetch("SUPPORT_PASSWORD", "test")
    )
  end

  def when_i_fill_teacher_email_address
    fill_in "teacher-email-field", with: "test@example.com"
  end

  def and_i_click_continue
    click_button "Continue", visible: false
  end

  def and_i_receive_a_teacher_confirmation_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq("Confirmation instructions")
    expect(message.to).to include("test@example.com")
  end

  def when_i_visit_the_teacher_confirmation_email
    message = ActionMailer::Base.deliveries.last
    uri = URI.parse(URI.extract(message.body.to_s).second)
    expect(uri.path).to eq("/teacher/confirmation")
    expect(uri.query).to include("confirmation_token=")
    visit "#{uri.path}?#{uri.query}"
  end
end

RSpec.configure { |config| config.include SystemHelpers, type: :system }
