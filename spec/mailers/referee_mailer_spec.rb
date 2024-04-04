# frozen_string_literal: true

require "rails_helper"

RSpec.describe RefereeMailer, type: :mailer do
  let(:application_form) do
    create(:application_form, given_names: "First", family_name: "Last")
  end

  let(:assessment) { create(:assessment, application_form:) }
  let(:work_history) do
    create(
      :work_history,
      application_form:,
      contact_name: "Contact Name",
      contact_email: "referee@school.com",
    )
  end

  let(:reference_request) do
    create(:requested_reference_request, assessment:, work_history:)
  end

  describe "#reference_reminder" do
    subject(:mail) do
      described_class.with(
        reference_request:,
        number_of_reminders_sent: 0,
      ).reference_reminder
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
          "Waiting on reference request for First Last’s application for QTS",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["referee@school.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear Contact Name") }
      it do
        is_expected.to include(
          "You need to answer a few questions about First Last",
        )
      end
      it do
        is_expected.to include(
          "http://localhost:3000/teacher/references/#{reference_request.slug}",
        )
      end
    end
  end

  describe "#reference_requested" do
    subject(:mail) do
      described_class.with(reference_request:).reference_requested
    end

    describe "#subject" do
      subject(:subject) { mail.subject }

      it do
        is_expected.to eq(
          "Reference request for First Last’s application for qualified teacher status (QTS)",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["referee@school.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.encoded }

      it { is_expected.to include("Dear Contact Name") }
      it do
        is_expected.to include(
          "You need to answer a few questions about First Last",
        )
      end
      it do
        is_expected.to include(
          "http://localhost:3000/teacher/references/#{reference_request.slug}",
        )
      end
    end
  end
end
