# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityDomains::ApplicationFormsCounterJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(eligibility_domain) }

    let(:eligibility_domain) { create :eligibility_domain }

    context "when there are no work history matches" do
      it "sets application_forms_count to 0" do
        perform

        expect(eligibility_domain.application_forms_count).to eq(0)
      end
    end

    context "when there is a single work history matches with application form" do
      let(:application_form) { create :application_form, :submitted }

      before { create(:work_history, eligibility_domain:, application_form:) }

      it "sets application_forms_count to 1" do
        perform

        expect(eligibility_domain.application_forms_count).to eq(1)
      end
    end

    context "when there are multiple work history matches from different application forms" do
      let(:application_form_one) { create :application_form, :submitted }
      let(:application_form_two) { create :application_form, :submitted }

      before do
        create :work_history,
               eligibility_domain:,
               application_form: application_form_one
        create :work_history,
               eligibility_domain:,
               application_form: application_form_two
      end

      it "sets application_forms_count to 2" do
        perform

        expect(eligibility_domain.application_forms_count).to eq(2)
      end
    end

    context "when there are multiple work history matches from same application form" do
      let(:application_form) { create :application_form, :submitted }

      before do
        create(:work_history, eligibility_domain:, application_form:)
        create(:work_history, eligibility_domain:, application_form:)
      end

      it "sets application_forms_count to 1" do
        perform

        expect(eligibility_domain.application_forms_count).to eq(1)
      end
    end
  end
end
