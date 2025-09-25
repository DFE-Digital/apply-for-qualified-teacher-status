# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::CreateEligibilityDomainForm, type: :model do
  subject { described_class.new(created_by:, domain:, note:) }

  let(:created_by) { create(:staff) }
  let(:domain) { "validdomain.co.uk" }
  let(:note) { "A note." }

  describe "validations" do
    it { is_expected.to validate_presence_of(:created_by) }
    it { is_expected.to validate_presence_of(:domain) }
    it { is_expected.to validate_presence_of(:note) }

    context "when there is another eligibility domain record with the same domain" do
      let(:domain) { "VALIDDOMAIN.co.uk" }

      before { create(:eligibility_domain, domain: "validdomain.co.uk") }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:domain]).to include(
          "You cannot add this email domain because a record with this domain already exists",
        )
      end
    end

    context "when the domain includes invalid characters" do
      let(:domain) { "@validdomain.co.uk" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:domain]).to include(
          "Enter an email domain in the correct format",
        )
      end
    end
  end

  describe "#save" do
    it "creates a eligibility domain record" do
      expect { subject.save }.to change(EligibilityDomain, :count).by(1)

      eligibility_domain = EligibilityDomain.last

      expect(eligibility_domain.created_by).to eq(created_by)
      expect(eligibility_domain.domain).to eq(domain)
    end

    it "records a timeline event" do
      expect { subject.save }.to have_recorded_timeline_event(
        :eligibility_domain_created,
        creator: created_by,
        note_text: note,
      )
    end
  end
end
