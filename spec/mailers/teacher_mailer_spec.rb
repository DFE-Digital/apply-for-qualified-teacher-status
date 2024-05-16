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
      subject(:subject) { mail.subject }

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
      subject(:subject) { mail.subject }

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
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
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
        is_expected.to include(
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
      subject(:subject) { mail.subject }

      context "with two weeks to go" do
        let(:number_of_reminders_sent) { 0 }

        it do
          is_expected.to eq("Your draft QTS application has not been submitted")
        end
      end

      context "with one week to go" do
        let(:number_of_reminders_sent) { 1 }

        it do
          is_expected.to eq("Your draft QTS application is about to be deleted")
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
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }

      context "with two weeks to go" do
        let(:number_of_reminders_sent) { 0 }

        it do
          is_expected.to include(
            "You have a draft application for qualified teacher status (QTS) in England that has not been submitted.",
          )
        end
        it do
          is_expected.to include(
            "Applications need to be submitted within 6 months of being started.",
          )
        end
      end

      context "with one week to go" do
        let(:number_of_reminders_sent) { 1 }

        it do
          is_expected.to include(
            "We recently contacted you about your draft application for qualified teacher " \
              "status (QTS) in England that has not been submitted.",
          )
        end
        it do
          is_expected.to include(
            "Applications need to be submitted within 6 months of being started.",
          )
        end
      end
    end
  end

  describe "#application_received" do
    subject(:mail) do
      described_class.with(application_form:).application_received
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
          "We’ve received your application for qualified teacher status (QTS)",
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
      it { is_expected.to include("abc") }

      it do
        is_expected.to include(
          "Your application will be entered into a queue and assigned a QTS assessor. This can take several weeks.",
        )
      end

      context "if the teaching authority provides the written statement" do
        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
        end

        it do
          is_expected.to include(
            "Once the written evidence is received and checked, your application will be entered into " \
              "a queue and assigned a QTS assessor. This can take several weeks.",
          )
        end
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
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
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
      it do
        is_expected.to include(
          "We recently wrote to you asking for your consent",
        )
      end
      it do
        is_expected.to include("If you do not send them by 12 February 2020")
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
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
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
      it do
        is_expected.to include(
          "As part of your QTS application we need to verify some of your qualifications",
        )
      end
      it do
        is_expected.to include("upload these documents by 12 February 2020")
      end
    end
  end

  describe "#consent_submitted" do
    subject(:mail) { described_class.with(application_form:).consent_submitted }

    describe "#subject" do
      subject(:subject) { mail.subject }

      it { is_expected.to eq("We’ve received your consent documents") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it do
        is_expected.to include("Thank you for submitting the consent documents")
      end
      it { is_expected.to include("Application reference number: abc") }
    end
  end

  describe "#further_information_received" do
    subject(:mail) do
      described_class.with(application_form:).further_information_received
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

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
      create(:further_information_request, assessment:)
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      it { is_expected.to eq("Your QTS application: More information needed") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it do
        is_expected.to include(
          "The assessor reviewing your QTS application needs more information.",
        )
      end
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }
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
      subject(:subject) { mail.subject }

      it { is_expected.to eq("Your QTS application: information still needed") }
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body }

      it { is_expected.to include("Dear First Last") }
      it do
        is_expected.to include(
          "If you do not respond by 12 February 2020 " \
            "then your QTS application will be declined.",
        )
      end
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }
    end
  end

  describe "#professional_standing_received" do
    subject(:mail) do
      described_class.with(application_form:).professional_standing_received
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
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
        is_expected.to include(
          "We have received your Letter of Professional Standing from the teaching " \
            "authority and attached it to your application.",
        )
      end
    end
  end

  describe "#references_reminder" do
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
    subject(:mail) do
      described_class.with(
        application_form:,
        number_of_reminders_sent:,
        reference_requests: [reference_request],
      ).references_reminder
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      context "with no reminder emails" do
        let(:number_of_reminders_sent) { 0 }
        it { is_expected.to eq("Waiting on references – QTS application") }
      end

      context "with one reminder email" do
        let(:number_of_reminders_sent) { 1 }
        it do
          is_expected.to eq(
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
        is_expected.to include(
          "We’re still waiting for a response from one or more of the " \
            "references you provided to verify your work history.",
        )
      end
      it { is_expected.to include("John Smith — St Smith School") }

      context "when the second reminder email" do
        let(:number_of_reminders_sent) { 1 }

        it do
          is_expected.to include(
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
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq("We’ve contacted your references – QTS application")
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
        is_expected.to include(
          "We’ve contacted the following references you provided to verify the work " \
            "history information you gave as part of your QTS application.",
        )
      end
    end
  end
end
