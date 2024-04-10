# frozen_string_literal: true

module SystemHelpers
  include PageHelpers
  include Warden::Test::Helpers

  def given_an_eligible_eligibility_check(country_check:)
    country = create(:country, :with_national_region, code: "GB-SCT")
    country.regions.first.update!(
      qualifications_information: "Qualifications information",
      requires_preliminary_check: true,
      status_check: country_check,
      sanction_check: country_check,
      status_information: "Status information",
      sanction_information: "Sanction information",
      other_information: "Other teaching authority information.",
    )

    visit "/eligibility/start"
    click_button "Start now"

    if FeatureFlags::FeatureFlag.active?(:teacher_applications)
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
    choose "More than 20 months", visible: false
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
    user = create(:staff, :with_support_console_permission, name: "Admin")
    given_i_am_authorized_as_a_user(user)
  end

  def given_i_am_authorized_as_an_assessor_user
    user = create(:staff, :with_assess_permission, name: "Authorized User")
    given_i_am_authorized_as_a_user(user)
  end

  def given_i_am_authorized_as_an_admin_user
    user = create(:staff, :with_verify_permission, name: "Authorized User")
    given_i_am_authorized_as_a_user(user)
  end

  def given_malware_scanning_is_enabled(scan_result: "No threats found")
    FeatureFlags::FeatureFlag.activate(:fetch_malware_scan_result)
    tags_url = "https://example.com/uploads/abc987xyz123?comp=tags"
    response_body = <<-XML.squish
      <Tags>
        <Tag>
          <Key>Malware Scanning scan result</Key>
          <Value>#{scan_result}</Value>
        </Tag>
      </Tags>
    XML
    stubbed_service =
      instance_double(Azure::Storage::Blob::BlobService, generate_uri: tags_url)
    stubbed_response =
      instance_double(
        Azure::Core::Http::HttpResponse,
        success?: true,
        body: response_body,
      )
    allow(Azure::Storage::Blob::BlobService).to receive(:new).and_return(
      stubbed_service,
    )
    allow(stubbed_service).to receive(:call).and_return(stubbed_response)
  end

  def given_malware_scanning_is_disabled
    FeatureFlags::FeatureFlag.deactivate(:fetch_malware_scan_result)
  end

  def when_i_sign_out
    sign_out @user
  end

  alias_method :then_i_sign_out, :when_i_sign_out

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

  def then_i_see_the_sign_in_form
    expect(teacher_sign_in_page).to have_title(
      "Apply for qualified teacher status (QTS) in England",
    )
    expect(teacher_sign_in_page).to have_content("Email address")
  end

  def then_i_see_the_forbidden_page
    expect(page).to have_title("Forbidden")
    expect(page).to have_content("Forbidden")
    expect(page).to have_content("You do not have access to view this page.")
  end
end

RSpec.configure { |config| config.include SystemHelpers, type: :system }
