# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor unlink applicant GOV.UK One Login", type: :system do
  let(:teacher) { create :teacher, gov_one_id: "gov-one-uuid" }

  let!(:application_form) do
    create(
      :application_form,
      :submitted,
      :with_personal_information,
      :with_assessment,
      teacher:,
    )
  end

  context "when user does not have assess permission" do
    before { given_i_am_authorized_as_a_user(view_only_staff) }

    it "does not allow access to edit unlink one login page" do
      when_i_visit_the(:assessor_edit_unlink_one_login_page, reference:)
      then_i_see_the_forbidden_page
    end

    it "does not show unlink GOV.UK One Login link on overview page" do
      when_i_visit_the(:assessor_application_page, reference:)
      then_i_see_the(:assessor_application_page)
      expect(
        assessor_application_page.summary_list.find_row(
          key: "GOV.UK One Login",
        ),
      ).to have_no_actions
    end
  end

  context "when user has assess permission" do
    before { given_i_am_authorized_as_a_user(assessor) }

    it "allows unlinking the applicant GOV.UK One Login" do
      when_i_visit_the(:assessor_application_page, reference:)
      then_i_see_the(:assessor_application_page)

      when_i_click_on_unlink_one_login_link
      then_i_see_the(:assessor_edit_unlink_one_login_page, reference:)

      when_i_confirm_to_unlink
      then_i_see_the(:assessor_application_page, reference:)
      and_i_see_that_that_one_login_has_been_unlinked
    end

    it "does not unlink the applicant GOV.UK One Login if not confirmed" do
      when_i_visit_the(:assessor_application_page, reference:)
      then_i_see_the(:assessor_application_page)

      when_i_click_on_unlink_one_login_link
      then_i_see_the(:assessor_edit_unlink_one_login_page, reference:)

      when_i_do_not_confirm_to_unlink
      then_i_see_the(:assessor_application_page, reference:)
      and_i_see_that_that_one_login_has_not_been_unlinked
    end

    it "does not allow any access if user is archived" do
      given_i_am_authorized_as_an_archived_user(archived_assessor)

      when_i_visit_the(:assessor_edit_unlink_one_login_page, reference:)
      then_i_see_the_forbidden_page
    end
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_on_unlink_one_login_link
    assessor_application_page
      .summary_list
      .find_row(key: "GOV.UK One Login")
      .actions
      .link
      .click
  end

  def when_i_confirm_to_unlink
    assessor_edit_unlink_one_login_page.form.true_radio_item.click
    assessor_edit_unlink_one_login_page.form.submit_button.click
  end

  def when_i_do_not_confirm_to_unlink
    assessor_edit_unlink_one_login_page.form.false_radio_item.click
    assessor_edit_unlink_one_login_page.form.submit_button.click
  end

  def and_i_see_that_that_one_login_has_been_unlinked
    expect(
      assessor_application_page
        .summary_list
        .find_row(key: "GOV.UK One Login")
        .value
        .text,
    ).to eq("Unlinked")
  end

  def and_i_see_that_that_one_login_has_not_been_unlinked
    expect(
      assessor_application_page
        .summary_list
        .find_row(key: "GOV.UK One Login")
        .value
        .text,
    ).to eq("Linked")
  end

  delegate :reference, to: :application_form

  def view_only_staff
    create(:staff)
  end

  def assessor
    create(:staff, :with_assess_permission)
  end

  def archived_assessor
    create(:staff, :with_assess_permission, :archived)
  end
end
