require "rails_helper"

RSpec.describe TeacherMailer, type: :mailer do
  let(:teacher) { create(:teacher, email: "teacher@example.com") }
  before do
    create(
      :application_form,
      teacher:,
      reference: "abc",
      given_names: "First",
      family_name: "Last",
    )
  end

  describe "application_received" do
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
      it { is_expected.to include("http://localhost:3000/teacher/sign_in") }
    end
  end
end
