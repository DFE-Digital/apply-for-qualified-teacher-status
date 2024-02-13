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
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }
      it { is_expected.to include("ABCDEF") }
      it { is_expected.to include("https://aytq.com") }
    end

    it_behaves_like "an observable mailer", "application_awarded"
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
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }
      it { is_expected.to include("Reason for decline") }
    end

    it_behaves_like "an observable mailer", "application_declined"
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
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it do
        is_expected.to include(
          "As we are unable to verify professional standing documents with the teaching authority in France, we " \
            "have removed France from the list of eligible countries.",
        )
      end
    end

    it_behaves_like "an observable mailer",
                    "application_from_ineligible_country"
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
          is_expected.to eq(
            "Your draft QTS application will be deleted in 2 weeks",
          )
        end
      end

      context "with one week to go" do
        let(:number_of_reminders_sent) { 1 }

        it do
          is_expected.to eq(
            "Your draft QTS application will be deleted in 1 week",
          )
        end
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }

      context "with two weeks to go" do
        let(:number_of_reminders_sent) { 0 }

        it do
          is_expected.to include(
            "We’ve noticed that you have a draft application for qualified " \
              "teacher status (QTS) that has not been submitted.",
          )
        end
        it do
          is_expected.to include(
            "We need to let you know that if you do not complete and submit " \
              "your application by 1 July 2020 we’ll delete the application.",
          )
        end
      end

      context "with one week to go" do
        let(:number_of_reminders_sent) { 1 }

        it do
          is_expected.to include(
            "We contacted you a week ago about your draft application for qualified teacher status (QTS).",
          )
        end
        it do
          is_expected.to include(
            "If you do not complete and submit your application by 1 July 2020 we’ll delete the application.",
          )
        end
      end
    end

    it_behaves_like "an observable mailer", "application_not_submitted"
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
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }

      it do
        is_expected.to include(
          "Your application will be entered into a queue and assigned a QTS assessor, which can take several weeks.",
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
            "When we’ve received the written evidence you’ve requested from your teaching authority, we’ll " \
              "add your application to the queue to be assigned to a QTS assessor — this can take several weeks.",
          )
        end
      end
    end

    it_behaves_like "an observable mailer", "application_received"
  end

  describe "#consent_requested" do
    subject(:mail) { described_class.with(application_form:).consent_requested }

    before do
      create(
        :qualification_request,
        :consent_requested,
        assessment:,
        consent_requested_at: Date.new(2020, 1, 1),
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
      subject(:body) { mail.body.encoded }

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

    it_behaves_like "an observable mailer", "consent_requested"
  end

  describe "#further_information_received" do
    subject(:mail) do
      described_class.with(application_form:).further_information_received
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
          "We’ve received the additional information you sent us",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }
    end

    it_behaves_like "an observable mailer", "further_information_received"
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

      it do
        is_expected.to eq(
          "We need some more information to progress your QTS application",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it do
        is_expected.to include(
          "The assessor reviewing your QTS application needs more information.",
        )
      end
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }
    end

    it_behaves_like "an observable mailer", "further_information_requested"
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

      it do
        is_expected.to eq(
          "We still need some more information to progress your QTS application",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it do
        is_expected.to include(
          "You must respond to this request by 12 February 2020 " \
            "otherwise your QTS application will be declined.",
        )
      end
      it { is_expected.to include("abc") }
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }
    end

    it_behaves_like "an observable mailer", "further_information_reminder"
  end

  describe "#professional_standing_received" do
    subject(:mail) do
      described_class.with(application_form:).professional_standing_received
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
          "Your qualified teacher status application – we’ve received your " \
            "letter that proves you’re recognised as a teacher",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["teacher@example.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it { is_expected.to include("abc") }
      it do
        is_expected.to include(
          "Thank you for requesting your letter that proves you’re recognised as a teacher from " \
            "the teaching authority. We have now received this document and attached it " \
            "to your application.",
        )
      end
    end

    it_behaves_like "an observable mailer", "professional_standing_received"
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
      subject(:body) { mail.body.encoded }

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

    it_behaves_like "an observable mailer", "references_reminder"
  end

  describe "#references_requested" do
    subject(:mail) do
      described_class.with(
        application_form:,
        reference_requests: [
          create(:reference_request, :requested, assessment:),
        ],
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
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear First Last") }
      it do
        is_expected.to include(
          "We’ve contacted the references you provided to verify the work history",
        )
      end
    end

    it_behaves_like "an observable mailer", "references_requested"
  end
end
