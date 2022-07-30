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

  def given_the_service_allows_teacher_applications
    FeatureFlag.activate(:teacher_applications)
  end

  def given_an_eligible_eligibility_check
    country = create(:country, :with_national_region, code: "GB-SCT")
    country.regions.first.update!(status_check: :written)

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

  def when_i_choose_yes
    choose "Yes", visible: false
  end

  alias_method :and_i_choose_yes, :when_i_choose_yes

  def when_i_choose_no
    choose "No", visible: false
  end

  alias_method :and_i_choose_no, :when_i_choose_no

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

  def then_i_see_the_sign_in_form
    expect(page).to have_current_path("/teacher/sign_in")
    expect(page).to have_title("Create an account or sign in")
    expect(page).to have_content("Create an account or sign in")
  end

  def and_i_sign_up
    when_i_fill_teacher_email_address
    and_i_click_continue
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
  end
end

RSpec.configure { |config| config.include SystemHelpers, type: :system }
