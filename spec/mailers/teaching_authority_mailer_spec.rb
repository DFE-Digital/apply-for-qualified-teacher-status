# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeachingAuthorityMailer, type: :mailer do
  let(:region) do
    create(
      :region,
      name: "Region Name",
      teaching_authority_name: "Teaching Authority",
      teaching_authority_emails: ["authority@government.com"],
    )
  end

  let(:application_form) do
    create(
      :application_form,
      region:,
      reference: "abc",
      given_names: "First",
      family_name: "Last",
      date_of_birth: Date.new(1990, 1, 1),
      subjects: %w[Maths French],
      age_range_min: 8,
      age_range_max: 11,
    )
  end

  before do
    create(
      :qualification,
      application_form:,
      title: "Qualification Title",
      institution_name: "Institution",
      start_date: Date.new(2010, 1, 1),
      complete_date: Date.new(2015, 1, 1),
    )
  end

  describe "#application_submitted" do
    subject(:mail) do
      described_class.with(application_form:).application_submitted
    end

    describe "#subject" do
      subject { mail.subject }

      it do
        expect(subject).to eq(
          "First Last has made an application for qualified teacher status (QTS) in England",
        )
      end
    end

    describe "#to" do
      subject(:to) { mail.to }

      it { is_expected.to eq(["authority@government.com"]) }
    end

    describe "#body" do
      subject(:body) { mail.body.raw_source.gsub("\r", "") }

      it { is_expected.to eq(<<-EMAIL) }
Dear Teaching Authority

We can confirm that the following person has made an application to us for qualified teacher status (QTS) in England:

First Last

Date of birth: 1 January 1990

The applicant has provided us with the following details about their teaching qualification:

Title: Qualification Title
Institution studied at: Institution
Date started: 1 January 2010
Date ended: 1 January 2015

They’ve told us that they’re qualified to teach children Maths and French from age 8 to 11 years old.

We’d be grateful if you could provide written evidence of their professional standing as a teacher in Region Name, and email it to us at:

[ApplyQTS.Verification@education.gov.uk](mailto:ApplyQTS.Verification@education.gov.uk)

Please include their QTS application reference number abc.

Kind regards,
Teaching Regulation Agency (TRA)

TRA is an executive agency, sponsored by the Department for Education. We have responsibility for the regulation of the teaching profession in England.
      EMAIL
    end
  end
end
