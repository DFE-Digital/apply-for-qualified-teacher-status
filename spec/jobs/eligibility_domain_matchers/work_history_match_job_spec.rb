# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityDomainMatchers::WorkHistoryMatchJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(work_history) }

    let(:work_history) { create :work_history, :completed }

    context "when there are no eligibility domain matches" do
      it "does not match to any eligibility domains" do
        perform

        expect(work_history.eligibility_domain).to be_nil
      end
    end

    context "when there is a eligibility domain that is a match" do
      let!(:eligibility_domain) do
        create :eligibility_domain, domain: work_history.contact_email_domain
      end

      it "matches to any application forms" do
        perform

        expect(work_history.eligibility_domain).to eq(eligibility_domain)
        expect(eligibility_domain.reload.application_forms_count).to eq(1)
      end
    end

    context "when there is a eligibility domain that is not a match" do
      let!(:eligibility_domain) { create :eligibility_domain }

      it "does not match to any eligibility domains" do
        perform

        expect(work_history.eligibility_domain).to be_nil
        expect(eligibility_domain.reload.application_forms_count).to eq(0)
      end
    end
  end
end
