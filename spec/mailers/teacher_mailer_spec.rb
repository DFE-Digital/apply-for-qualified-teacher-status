require "rails_helper"

RSpec.describe TeacherMailer, type: :mailer do
  let(:teacher) { create(:teacher, email: "teacher@example.com") }
  let(:assessment) { create(:assessment) }

  let!(:application_form) do
    create(
      :application_form,
      teacher:,
      reference: "abc",
      given_names: "First",
      family_name: "Last",
      assessment:,
    )
  end

  shared_examples "observer metadata" do |expected_action_name|
    describe "#mailer_action_name" do
      subject(:mailer_action_name) { mail.mailer_action_name }

      it { is_expected.to eq(expected_action_name) }
    end

    describe "#application_form_id" do
      subject(:application_form_id) { mail.application_form_id }

      it { is_expected.to eq(application_form.id) }
    end
  end

  describe "#application_awarded" do
    subject(:mail) { described_class.with(teacher:).application_awarded }

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
    end

    include_examples "observer metadata", "application_awarded"
  end

  describe "#application_declined" do
    subject(:mail) { described_class.with(teacher:).application_declined }

    describe "#subject" do
      subject(:subject) { mail.subject }

      it { is_expected.to eq("Your QTS application has been declined") }
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
          "You can sign in to view the reason why your application was declined:",
        )
      end
    end

    include_examples "observer metadata", "application_declined"

    context "further information requested" do
      let(:assessment) do
        create(:assessment, :with_further_information_request)
      end

      describe "#body" do
        subject(:body) { mail.body.encoded }

        it do
          is_expected.to include(
            "You can sign in to explore other routes to teaching in England:",
          )
        end
      end
    end
  end

  describe "#application_not_submitted" do
    subject(:mail) do
      described_class.with(teacher:, duration:).application_not_submitted
    end

    let(:duration) { nil }

    describe "#subject" do
      subject(:subject) { mail.subject }

      context "with two weeks to go" do
        let(:duration) { "two_weeks" }
        it { is_expected.to eq("Your QTS application has not been submitted") }
      end

      context "with one week to go" do
        let(:duration) { "one_week" }
        it do
          is_expected.to eq("Your QTS application will be deleted in 1 week")
        end
      end

      context "with two days to go" do
        let(:duration) { "two_days" }
        it do
          is_expected.to eq("Your QTS application will be deleted in 2 days")
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
      it { is_expected.to include("you have a draft application") }
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }
    end

    include_examples "observer metadata", "application_not_submitted"
  end

  describe "#application_received" do
    subject(:mail) { described_class.with(teacher:).application_received }

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
    end

    include_examples "observer metadata", "application_received"
  end

  describe "#further_information_received" do
    subject(:mail) do
      described_class.with(teacher:).further_information_received
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

    include_examples "observer metadata", "further_information_received"
  end

  describe "#further_information_requested" do
    subject(:mail) do
      described_class.with(
        teacher:,
        further_information_request:,
      ).further_information_requested
    end

    let(:further_information_request) { create(:further_information_request) }

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

    include_examples "observer metadata", "further_information_requested"
  end

  describe "#further_information_reminder" do
    subject(:mail) do
      described_class.with(
        teacher:,
        further_information_request:,
        due_date:,
      ).further_information_reminder
    end

    let(:further_information_request) { create(:further_information_request) }
    let(:due_date) { 10.days.from_now }

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
          "You must respond to this request by #{due_date.strftime("%e %B %Y")} " \
            "otherwise your QTS application will be declined.",
        )
      end
      it { is_expected.to include("abc") }
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }
    end

    include_examples "observer metadata", "further_information_reminder"
  end
end
