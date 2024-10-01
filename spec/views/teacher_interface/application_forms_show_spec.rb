# frozen_string_literal: true

require "rails_helper"

RSpec.describe "teacher_interface/application_forms/show.html.erb",
               type: :view do
  subject { render }

  before do
    assign(
      :view_object,
      TeacherInterface::ApplicationFormViewObject.new(application_form:),
    )
  end

  context "when request further information" do
    let(:application_form) { create(:application_form, :submitted) }

    context "with the requested consent request not received" do
      before do
        create(:requested_further_information_request, application_form:)
      end

      it { is_expected.to match(/We need some more information/) }
    end

    context "with the requested consent request received" do
      before do
        create(:received_further_information_request, application_form:)
      end

      it { is_expected.to match(/Further information successfully submitted/) }
    end
  end

  context "when request qualification consent" do
    let(:application_form) { create(:application_form, :submitted) }

    context "with the requested consent request not received" do
      before { create :requested_consent_request, application_form: }

      it do
        expect(subject).to match(
          /We need your written consent to verify some of your qualifications/,
        )
      end
    end

    context "with the requested consent request received" do
      before { create :received_consent_request, application_form: }

      it { is_expected.to match(/Consent documents successfully submitted/) }
    end
  end

  context "when in draft" do
    let(:application_form) { create(:application_form) }

    it do
      expect(subject).to match(/Applications must be completed within 6 months/)
    end
  end

  context "when request professional standing certificate" do
    let(:application_form) do
      create :application_form,
             :with_assessment,
             :submitted,
             teaching_authority_provides_written_statement: true
    end

    before do
      create(
        :requested_professional_standing_request,
        assessment: application_form.assessment,
      )
    end

    it { is_expected.to match(/Application submitted/) }

    it do
      expect(subject).to match(
        /Your application cannot proceed until we receive your Letter of Professional Standing/,
      )
    end

    context "with requiring preliminary check that is still pending" do
      let(:application_form) do
        create :application_form,
               :with_assessment,
               :requires_preliminary_check,
               :submitted,
               teaching_authority_provides_written_statement: true
      end

      before do
        create(
          :assessment_section,
          :preliminary,
          assessment: application_form.assessment,
        )
      end

      it { is_expected.to match(/Application submitted/) }

      it do
        expect(subject).to match(
          /We need to carry out some initial checks on your application./,
        )
      end
    end

    context "with requiring preliminary check that has passed" do
      let(:application_form) do
        create :application_form,
               :with_assessment,
               :requires_preliminary_check,
               :submitted,
               teaching_authority_provides_written_statement: true
      end

      before do
        create(
          :assessment_section,
          :preliminary,
          assessment: application_form.assessment,
          passed: true,
        )
      end

      it { is_expected.to match(/Your application has passed initial checks/) }

      it do
        expect(subject).to match(
          /Your application cannot proceed until we receive your Letter of Professional Standing/,
        )
      end
    end
  end

  context "when from ineligible country" do
    let(:application_form) { create(:application_form) }

    before do
      application_form.region.country.update(eligibility_enabled: false)
    end

    it { is_expected.to match(/Your QTS application has been closed/) }
  end

  context "when awarded pending checks" do
    let(:application_form) do
      create(:application_form, :awarded_pending_checks)
    end

    it { is_expected.to match(/Application received/) }
    it { is_expected.to match(/We’ve received your application for QTS/) }
  end

  context "when awarded" do
    let(:teacher) { create(:teacher, trn: "ABCDEF") }
    let(:application_form) { create(:application_form, :awarded, teacher:) }

    it { is_expected.to match(/Your QTS application was successful/) }
    it { is_expected.to match(/ABCDEF/) }
    it { is_expected.to match(/Access your teaching qualifications/) }
  end

  context "when declined" do
    let(:application_form) { create(:application_form, :declined) }
    let!(:assessment) { create(:assessment, application_form:) }

    context "and an initial assessment" do
      before do
        create(
          :assessment_section,
          :failed,
          key: :personal_information,
          assessment:,
        )
      end

      it { is_expected.to match(/Your QTS application has been declined/) }
      it { is_expected.to match(/Reason for decline/) }
      it { is_expected.to match(/You’ll be able to make a new application/) }
    end

    context "and a further information request" do
      let(:further_information_request) do
        create(:further_information_request, assessment:)
      end

      before do
        create(
          :further_information_request_item,
          further_information_request:,
          failure_reason_assessor_feedback: "A note",
        )
      end

      it { is_expected.to match(/Your QTS application has been declined/) }
      it { is_expected.to match(/You’ll be able to make a new application/) }

      it "does not show the assessor notes to the applicant" do
        expect(subject).not_to match(/A note/)
      end
    end

    context "and an expired professional standing request" do
      before { create(:professional_standing_request, :expired, assessment:) }

      it do
        expect(subject).to match(/Your QTS application has been declined/)
        expect(subject).to match(
          /we did not receive your Letter of Professional Standing/,
        )
        expect(subject).to match(/from teaching authority within 180 days/)
      end
    end

    context "and with sanctions" do
      before do
        create(:assessment_section, :declines_with_sanctions, assessment:)
      end

      it do
        expect(subject).not_to match(/you can make a new application in future/)
      end
    end
  end
end
