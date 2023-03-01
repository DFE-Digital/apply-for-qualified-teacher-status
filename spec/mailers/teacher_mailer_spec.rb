# frozen_string_literal: true

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

    it_behaves_like "an observable mailer", "application_awarded"
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
          "You can sign in to find out why your application was declined:",
        )
      end
    end

    it_behaves_like "an observable mailer", "application_declined"

    context "further information requested" do
      let(:assessment) do
        create(:assessment, :with_further_information_request)
      end

      describe "#body" do
        subject(:body) { mail.body.encoded }

        it do
          is_expected.to include(
            "You can sign in to find out why your application was declined:",
          )
        end
      end
    end
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

    it_behaves_like "an observable mailer", "further_information_received"
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

    it_behaves_like "an observable mailer", "further_information_requested"
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

    it_behaves_like "an observable mailer", "further_information_reminder"
  end

  describe "#references_requested" do
    subject(:mail) { described_class.with(teacher:).references_requested }

    describe "#subject" do
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
          "Your qualified teacher status application – we’ve contacted your references",
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
          "We’ve contacted the references you provided to verify your work history",
        )
      end
    end

    it_behaves_like "an observable mailer", "references_requested"
  end
end
