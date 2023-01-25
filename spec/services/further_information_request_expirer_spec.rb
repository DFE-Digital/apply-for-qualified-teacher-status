# frozen_string_literal: true

require "rails_helper"

RSpec.describe FurtherInformationRequestExpirer do
  describe ".call" do
    let(:application_form) { create(:application_form, :submitted, region:) }
    let(:assessment) { create(:assessment, application_form:) }
    let(:further_information_request) do
      create(:further_information_request, created_at:, assessment:)
    end
    let(:region) { create(:region, :in_country, country_code: "FR") }

    let(:expected_assessor_note) do
      "Further information not supplied by deadline"
    end

    subject { described_class.call(further_information_request:) }

    shared_examples_for "expiring an FI request" do
      it { is_expected.to be_expired }

      it "declines the application" do
        expect(subject.assessment.application_form).to be_declined
      end

      it "sets the failure_assessor_note" do
        expect(subject.failure_assessor_note).to eq(expected_assessor_note)
      end

      it "sets the passed to false" do
        expect(subject.passed).to eq(false)
      end

      it "records a requestable requested timeline event" do
        expect { subject }.to have_recorded_timeline_event(:requestable_expired)
      end
    end

    context "with requested FI request" do
      context "when less than six weeks old" do
        let(:created_at) { (6.weeks - 1.hour).ago }

        it { is_expected.to be_requested }
      end

      context "when it is more than six weeks old" do
        let(:created_at) { (6.weeks + 1.hour).ago }

        it_behaves_like "expiring an FI request"
      end

      context "when the applicant is from a country with a 4 week expiry" do
        # Australia, Canada, Gibraltar, New Zealand, US
        %w[AU CA GI NZ US].each do |country_code|
          context "from country_code #{country_code}" do
            let(:region) { create(:region, :in_country, country_code:) }

            context "when it is less than four weeks old" do
              let(:created_at) { (4.weeks - 1.hour).ago }

              it { is_expected.to be_requested }
            end

            context "when it is more than four weeks old from #{country_code}" do
              let(:created_at) { (4.weeks + 1.hour).ago }

              it_behaves_like "expiring an FI request"
            end
          end
        end
      end
    end

    context "with any received FI request" do
      let(:further_information_request) do
        create(:further_information_request, :received, created_at: 1.year.ago)
      end

      it { is_expected.to be_received }
    end

    context "with any expired FI request" do
      let(:further_information_request) do
        create(:further_information_request, :expired, created_at: 1.year.ago)
      end

      it { is_expected.to be_expired }
    end
  end
end
