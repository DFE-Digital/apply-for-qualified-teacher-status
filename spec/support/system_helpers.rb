module SystemHelpers
  include PageHelpers
  include Warden::Test::Helpers

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_service_is_closed
    FeatureFlag.deactivate(:service_open)
  end

  def given_the_service_allows_teacher_applications
    FeatureFlag.activate(:teacher_applications)
  end

  def given_an_eligible_eligibility_check(country_check:)
    country = create(:country, :with_national_region, code: "GB-SCT")
    country.regions.first.update!(
      application_form_enabled: true,
      status_check: country_check,
      sanction_check: country_check,
      teaching_authority_status_information: "Status information",
      teaching_authority_sanction_information: "Sanction information",
      teaching_authority_other: "Other teaching authority information.",
    )

    visit "/eligibility/start"
    click_button "Start now"

    if FeatureFlag.active?(:teacher_applications)
      choose "No, I need to check if I can apply", visible: false
      and_i_click_continue
    end

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

  def given_an_eligible_eligibility_check_with_none_country_checks
    given_an_eligible_eligibility_check(country_check: :none)
  end

  def given_an_eligible_eligibility_check_with_online_country_checks
    given_an_eligible_eligibility_check(country_check: :online)
  end

  def given_an_eligible_eligibility_check_with_written_country_checks
    given_an_eligible_eligibility_check(country_check: :written)
  end

  def given_i_am_authorized_as_a_user(user)
    sign_in(@user = user)
  end

  def given_i_am_authorized_as_a_support_user
    user = create(:staff, :confirmed, :with_support_console_permission)
    given_i_am_authorized_as_a_user(user)
  end

  def given_i_am_authorized_as_an_assessor_user
    user =
      create(
        :staff,
        :with_award_decline_permission,
        :confirmed,
        name: "Authorized User",
      )
    given_i_am_authorized_as_a_user(user)
  end

  def when_i_am_authorized_as_a_test_user
    page.driver.basic_authorize(
      ENV.fetch("TEST_USERNAME", "test"),
      ENV.fetch("TEST_PASSWORD", "test"),
    )
  end

  def when_i_sign_out
    sign_out @user
  end

  alias_method :then_i_sign_out, :when_i_sign_out

  def given_the_test_user_is_disabled
    FeatureFlag.deactivate(:staff_test_user)
  end

  def given_the_test_user_is_enabled
    FeatureFlag.activate(:staff_test_user)
  end

  def when_i_choose_yes
    choose "Yes", visible: false
  end

  alias_method :and_i_choose_yes, :when_i_choose_yes

  def when_i_choose_no
    choose "No", visible: false
  end

  alias_method :and_i_choose_no, :when_i_choose_no

  def and_i_click_continue
    click_button "Continue", visible: false
  end

  alias_method :when_i_click_continue, :and_i_click_continue

  def and_i_receive_a_teacher_otp_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq("Confirm your email address")
    expect(message.to).to include("test@example.com")
  end

  def when_i_fill_in_the_teacher_otp
    message = ActionMailer::Base.deliveries.last
    otp = message.body.encoded.lines.third.chomp
    teacher_confirm_otp_page.submit(otp:)
  end

  def then_i_see_the_sign_in_form
    expect(teacher_sign_in_page).to have_title(
      "Apply for qualified teacher status (QTS) in England",
    )
    expect(teacher_sign_in_page).to have_content("Email address")
  end

  def and_i_sign_up
    teacher_sign_up_page.submit(email: "test@example.com")
    and_i_receive_a_teacher_otp_email
    when_i_fill_in_the_teacher_otp
  end

  def then_i_see_the_forbidden_page
    expect(page).to have_title("Forbidden")
    expect(page).to have_content("Forbidden")
    expect(page).to have_content("You do not have access to view this page.")
  end
end

RSpec.configure { |config| config.include SystemHelpers, type: :system }
