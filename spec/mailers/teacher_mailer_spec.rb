# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherMailer, type: :mailer do
  let(:teacher) { create(:teacher, email: "teacher@example.com") }
  let(:assessment) { create(:assessment) }

  let!(:application_form) do
    create(
      :application_form,
      assessment:,
      created_at: Date.new(2020, 1, 1),
      family_name: "Last",
      given_names: "First",
      reference: "abc",
      region: create(:region, :in_country, country_code: "FR"),
      teacher:,
    )
  end

  let(:qualification) { create(:qualification, application_form:) }

  describe "#application_awarded" do
    subject(:mail) do
      described_class.with(application_form:).application_awarded
    end

    before do
      teacher.update!(
        trn: "ABCDEF",
        access_your_teaching_qualifications_url: "https://aytq.com",
      )
    end

    describe "#subject" do
      subject { mail.subject }

      it { is_expected.to eq("Your QTS application was successful") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }
      it { is_expected.to include("ABCDEF") }
      it { is_expected.to include("https://aytq.com") }
    end
  end

  describe "#application_declined" do
    subject(:mail) do
      described_class.with(application_form:).application_declined
    end

    describe "#subject" do
      subject { mail.subject }

      it { is_expected.to eq("Your QTS application was unsuccessful") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }
      it { is_expected.to include("Reason for decline") }
    end
  end

  describe "#application_from_ineligible_country" do
    subject(:mail) do
      described_class.with(
        application_form:,
      ).application_from_ineligible_country
    end

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "Update: Your qualified teacher status (QTS) application",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }

      it do
        expect(subject).to include(
          "As we are unable to verify professional standing documents with the teaching authority in France, we " \
            "have removed France from the list of eligible countries.",
        )
      end
    end
  end

  describe "#application_not_submitted" do
    subject(:mail) do
      described_class.with(
        application_form:,
        number_of_reminders_sent:,
      ).application_not_submitted
    end

    let(:number_of_reminders_sent) { nil }

    describe "#subject" do
      subject { mail.subject }

      context "with two weeks to go" do
        let(:number_of_reminders_sent) { 0 }

        it do
          expect(subject).to eq(
            "Your draft QTS application has not been submitted",
          )
        end
      end

      context "with one week to go" do
        let(:number_of_reminders_sent) { 1 }

        it do
          expect(subject).to eq(
            "Your draft QTS application is about to be deleted",
          )
        end
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("Sign in to your application") }
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }

      it do
        expect(subject).not_to include(
          "Create your GOV.UK One Login or sign in",
        )
      end

      context "with two weeks to go" do
        let(:number_of_reminders_sent) { 0 }

        it do
          expect(subject).to include(
            "You have a draft application for qualified teacher status (QTS) in England that has not been submitted.",
          )
        end

        it do
          expect(subject).to include(
            "Applications need to be submitted within 6 months of being started.",
          )
        end
      end

      context "with one week to go" do
        let(:number_of_reminders_sent) { 1 }

        it do
          expect(subject).to include(
            "We recently contacted you about your draft application for qualified teacher " \
              "status (QTS) in England that has not been submitted.",
          )
        end

        it do
          expect(subject).to include(
            "Applications need to be submitted within 6 months of being started.",
          )
        end
      end

      context "with the GOV.UK One Login feature enabled" do
        around do |example|
          FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
          example.run
          FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
        end

        it { is_expected.to include("Create your GOV.UK One Login or sign in") }
        it { is_expected.not_to include("Sign in to your application") }
      end
    end
  end

  describe "#application_received" do
    subject(:mail) do
      described_class.with(application_form:).application_received
    end

    describe "#subject" do
      subject { mail.subject }

      context "if the teaching authority provides the written statement" do
        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
        end

        it do
          expect(subject).to include(
            "Your QTS application: Awaiting Letter of Professional Standing",
          )
        end
      end

      context "if the teaching authority does not provide the written statement" do
        let(:certificate) { region_certificate_name(application_form.region) }

        before do
          application_form.update!(
            teaching_authority_provides_written_statement: false,
          )
        end

        it { is_expected.to include("Your QTS application has been received") }
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }

      it do
        expect(subject).to include(
          "Your application will be assessed by a trained assessor. They will check all the " \
            "information you have submitted.",
        )
      end
    end
  end

  describe "#consent_reminder" do
    subject(:mail) { described_class.with(application_form:).consent_reminder }

    before do
      create(
        :consent_request,
        :requested,
        assessment:,
        requested_at: Date.new(2020, 1, 1),
        qualification:,
      )
    end

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "Reminder: we need your written consent to progress your QTS application",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("Sign in to access your documents") }

      it do
        expect(subject).not_to include(
          "Create your GOV.UK One Login or sign in",
        )
      end

      it do
        expect(subject).to include(
          "We recently wrote to you asking for your consent",
        )
      end

      it do
        expect(subject).to include(
          "If you do not send them by 12 February 2020",
        )
      end

      context "with the GOV.UK One Login feature enabled" do
        around do |example|
          FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
          example.run
          FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
        end

        it { is_expected.to include("Create your GOV.UK One Login or sign in") }
        it { is_expected.not_to include("Sign in to access your documents") }
      end
    end
  end

  describe "#consent_requested" do
    subject(:mail) { described_class.with(application_form:).consent_requested }

    before do
      create(
        :consent_request,
        assessment:,
        requested_at: Date.new(2020, 1, 1),
        qualification:,
      )
    end

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "We need your written consent to progress your QTS application",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("Sign in to access your documents") }

      it do
        expect(subject).not_to include(
          "Create your GOV.UK One Login or sign in",
        )
      end

      it do
        expect(subject).to include(
          "As part of your QTS application we need to verify some of your qualifications",
        )
      end

      it do
        expect(subject).to include("upload these documents by 12 February 2020")
      end

      context "with the GOV.UK One Login feature enabled" do
        around do |example|
          FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
          example.run
          FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
        end

        it { is_expected.to include("Create your GOV.UK One Login or sign in") }
        it { is_expected.not_to include("Sign in to access your documents") }
      end
    end
  end

  describe "#consent_submitted" do
    subject(:mail) { described_class.with(application_form:).consent_submitted }

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "Your QTS application: consent documents received",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }

      it do
        expect(subject).to include(
          "Thank you for submitting the consent documents",
        )
      end

      it { is_expected.to include("Application reference number: abc") }
    end
  end

  describe "#further_information_received" do
    subject(:mail) do
      described_class.with(application_form:).further_information_received
    end

    describe "#subject" do
      subject { mail.subject }

      it { is_expected.to eq("Your QTS application: information received") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
    end
  end

  describe "#further_information_requested" do
    subject(:mail) do
      described_class.with(
        application_form:,
        further_information_request:,
      ).further_information_requested
    end

    let(:further_information_request) do
      create(:further_information_request, :requested, assessment:)
    end

    describe "#subject" do
      subject { mail.subject }

      it { is_expected.to eq("Your QTS application: More information needed") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("Sign in to your application") }

      it do
        expect(subject).not_to include(
          "Create your GOV.UK One Login or sign in",
        )
      end

      it do
        expect(subject).to include(
          "The assessor reviewing your QTS application needs more information.",
        )
      end

      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }

      context "with the GOV.UK One Login feature enabled" do
        around do |example|
          FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
          example.run
          FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
        end

        it { is_expected.to include("You will need a DfE Sign-in login to sign in") }
        it { is_expected.not_to include("Sign in to your application") }
      end
    end
  end

  describe "#further_information_reminder" do
    subject(:mail) do
      described_class.with(
        application_form:,
        further_information_request:,
      ).further_information_reminder
    end

    let(:further_information_request) do
      create(
        :further_information_request,
        assessment:,
        requested_at: Date.new(2020, 1, 1),
      )
    end

    describe "#subject" do
      subject { mail.subject }

      it { is_expected.to eq("Your QTS application: information still needed") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("Sign in to your application") }

      it do
        expect(subject).not_to include(
          "Create your GOV.UK One Login or sign in",
        )
      end

      it do
        expect(subject).to include(
          "If you do not respond by 12 February 2020 " \
            "then your QTS application will be declined.",
        )
      end

      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }

      context "with the GOV.UK One Login feature enabled" do
        around do |example|
          FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
          example.run
          FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
        end

        it { is_expected.to include("Create your GOV.UK One Login or sign in") }
        it { is_expected.not_to include("Sign in to your application") }
      end
    end
  end

  describe "#initial_checks_required" do
    subject(:mail) do
      described_class.with(application_form:).initial_checks_required
    end

    describe "#subject" do
      subject { mail.subject }

      it { is_expected.to eq("Your QTS application: Initial checks required") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }

      it do
        expect(subject).to include(
          "We need to carry out some initial checks on your application",
        )
      end
    end
  end

  describe "#professional_standing_received" do
    subject(:mail) do
      described_class.with(application_form:).professional_standing_received
    end

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "Your QTS application: Letter of Professional Standing received",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }

      it do
        expect(subject).to include(
          "We’ve received and checked your Letter of Professional Standing from the teaching " \
            "authority. This has been attached to your application.",
        )
      end
    end
  end

  describe "#professional_standing_requested" do
    subject(:mail) do
      described_class.with(application_form:).professional_standing_requested
    end

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "Your QTS application: Request your Letter of Professional Standing",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }

      it do
        expect(subject).to include(
          "We’ve received your application for qualfied teacher status (QTS) in England",
        )
      end

      context "when the application had required preliminary checks" do
        before { application_form.update!(requires_preliminary_check: true) }

        it do
          expect(subject).to include(
            "Your application has passed initial checks",
          )
        end
      end
    end
  end

  describe "#references_reminder" do
    subject(:mail) do
      described_class.with(
        application_form:,
        number_of_reminders_sent:,
        reference_requests: [reference_request],
      ).references_reminder
    end

    let(:reference_request) do
      create(
        :reference_request,
        assessment:,
        requested_at: Date.new(2020, 1, 1),
        work_history:
          create(
            :work_history,
            application_form:,
            contact_name: "John Smith",
            school_name: "St Smith School",
          ),
      )
    end
    let(:number_of_reminders_sent) { nil }

    describe "#subject" do
      subject { mail.subject }

      context "with no reminder emails" do
        let(:number_of_reminders_sent) { 0 }

        it { is_expected.to eq("Waiting on references – QTS application") }
      end

      context "with one reminder email" do
        let(:number_of_reminders_sent) { 1 }

        it do
          expect(subject).to eq(
            "Your references only have two weeks left to respond",
          )
        end
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      let(:number_of_reminders_sent) { 0 }

      it { is_expected.to include("Dear First Last") }

      it do
        expect(subject).to include(
          "We’re still waiting for a response from one or more of the " \
            "references you provided to verify your work history.",
        )
      end

      it { is_expected.to include("John Smith — St Smith School") }

      context "when the second reminder email" do
        let(:number_of_reminders_sent) { 1 }

        it do
          expect(subject).to include(
            "The following references have just 2 weeks to respond to the reference request.",
          )
        end
      end
    end
  end

  describe "#references_requested" do
    subject(:mail) do
      described_class.with(
        application_form:,
        reference_requests: [create(:requested_reference_request, assessment:)],
      ).references_requested
    end

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "We’ve contacted your references – QTS application",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }

      it do
        expect(subject).to include(
          "We’ve contacted the following references you provided to verify the work " \
            "history information you gave as part of your QTS application.",
        )
      end
    end
  end
end
