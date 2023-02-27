# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireRequestable do
  describe "#call" do
    let(:region) { create(:region, :in_country, country_code: "FR") }
    let(:application_form) { create(:application_form, :submitted, region:) }
    let(:assessment) { create(:assessment, application_form:) }

    subject { described_class.call(requestable:) }

    shared_examples_for "expiring a requestable" do
      it { is_expected.to be_expired }

      it "records a requestable requested timeline event" do
        expect { subject }.to have_recorded_timeline_event(:requestable_expired)
      end
    end

    shared_examples_for "declining the application" do
      it "declines the application" do
        expect(subject.assessment.application_form).to be_declined
      end
    end

    context "with requested FI request" do
      let(:requestable) do
        create(:further_information_request, created_at:, assessment:)
      end

      context "when less than six weeks old" do
        let(:created_at) { (6.weeks - 1.hour).ago }

        it { is_expected.to be_requested }
      end

      context "when it is more than six weeks old" do
        let(:created_at) { (6.weeks + 1.hour).ago }

        it_behaves_like "expiring a requestable"
        it_behaves_like "declining the application"
      end

      context "when the applicant is from a country with a 4 week expiry" do
        let(:application_form) do
          create(:application_form, :submitted, :old_regs, region:)
        end

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

              it_behaves_like "expiring a requestable"
              it_behaves_like "declining the application"
            end
          end
        end
      end
    end

    context "with any received FI request" do
      let(:requestable) do
        create(:further_information_request, :received, created_at: 1.year.ago)
      end

      it { is_expected.to be_received }
    end

    context "with any expired FI request" do
      let(:requestable) do
        create(:further_information_request, :expired, created_at: 1.year.ago)
      end

      it { is_expected.to be_expired }
    end

    context "with a requested professional standing request" do
      let(:requestable) { create(:professional_standing_request, created_at:) }

      context "when less than 18 weeks old" do
        let(:created_at) { (18.weeks - 1.hour).ago }

        it { is_expected.to be_requested }
      end

      context "when it is more than 18 weeks old" do
        let(:created_at) { (18.weeks + 1.hour).ago }

        it_behaves_like "expiring a requestable"
        it_behaves_like "declining the application"
      end
    end

    context "with any received professional standing request" do
      let(:requestable) do
        create(
          :professional_standing_request,
          :received,
          created_at: 1.year.ago,
        )
      end

      it { is_expected.to be_received }
    end

    context "with any expired professional standing request" do
      let(:requestable) do
        create(:professional_standing_request, :expired, created_at: 1.year.ago)
      end

      it { is_expected.to be_expired }
    end

    context "with a requested reference request" do
      let(:requestable) { create(:reference_request, created_at:) }

      context "when less than six weeks old" do
        let(:created_at) { (6.weeks - 1.hour).ago }

        it { is_expected.to be_requested }
      end

      context "when it is more than six weeks old" do
        let(:created_at) { (6.weeks + 1.hour).ago }

        it_behaves_like "expiring a requestable"
      end
    end

    context "with any received reference request" do
      let(:requestable) do
        create(:reference_request, :received, created_at: 1.year.ago)
      end

      it { is_expected.to be_received }
    end

    context "with any expired reference request" do
      let(:requestable) do
        create(:reference_request, :expired, created_at: 1.year.ago)
      end

      it { is_expected.to be_expired }
    end
  end
end
