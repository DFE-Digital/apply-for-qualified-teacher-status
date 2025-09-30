# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityDomainMatchers::EligibilityDomainMatchJob,
               type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(eligibility_domain) }

    let(:eligibility_domain) { create :eligibility_domain }

    context "when there are no work history matches" do
      it "does not match to any application forms" do
        perform

        expect(eligibility_domain.work_histories.reload).to be_empty
        expect(eligibility_domain.application_forms_count).to eq(0)
      end
    end

    context "when there is a single work history matches with application form not submitted" do
      before do
        create :work_history, contact_email_domain: eligibility_domain.domain
      end

      it "does not match to any application forms" do
        perform

        expect(eligibility_domain.work_histories.reload).to be_empty
        expect(eligibility_domain.application_forms_count).to eq(0)
      end
    end

    context "when there is a single work history matches with application form submitted" do
      let(:application_form) { create :application_form, :submitted }
      let!(:matching_work_history) do
        create :work_history,
               contact_email_domain: eligibility_domain.domain,
               application_form:
      end

      it "matches to the application form" do
        perform

        expect(eligibility_domain.work_histories.reload).to contain_exactly(
          matching_work_history,
        )
        expect(eligibility_domain.application_forms_count).to eq(1)
      end
    end

    context "when there are multiple work history matches from different application forms" do
      let(:application_form_one) { create :application_form, :submitted }
      let(:application_form_two) { create :application_form, :submitted }

      let!(:matching_work_history_one) do
        create :work_history,
               contact_email_domain: eligibility_domain.domain,
               application_form: application_form_one
      end

      let!(:matching_work_history_two) do
        create :work_history,
               contact_email_domain: eligibility_domain.domain,
               application_form: application_form_two
      end

      it "matches to the application forms" do
        perform

        expect(eligibility_domain.work_histories.reload).to contain_exactly(
          matching_work_history_one,
          matching_work_history_two,
        )
        expect(eligibility_domain.application_forms_count).to eq(2)
      end
    end

    context "when there are multiple work history matches from same application form" do
      let(:application_form) { create :application_form, :submitted }

      let!(:matching_work_history_one) do
        create :work_history,
               contact_email_domain: eligibility_domain.domain,
               application_form:
      end
      let!(:matching_work_history_two) do
        create :work_history,
               contact_email_domain: eligibility_domain.domain,
               application_form:
      end

      it "matches to the application form" do
        perform

        expect(eligibility_domain.work_histories.reload).to contain_exactly(
          matching_work_history_one,
          matching_work_history_two,
        )
        expect(eligibility_domain.application_forms_count).to eq(1)
      end
    end
  end
end
