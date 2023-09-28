# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireRequestableJob do
  describe "#perform" do
    let(:region) { create(:region, :in_country, country_code: "FR") }
    let(:application_form) { create(:application_form, :submitted, region:) }
    let(:assessment) { create(:assessment, application_form:) }

    subject(:perform) { described_class.new.perform(requestable) }

    shared_examples_for "not expired requestable" do
      it "doesn't expire" do
        expect(ExpireRequestable).to_not receive(:call).with(
          requestable:,
          user: a_kind_of(String),
        )
        perform
      end
    end

    shared_examples_for "expired requestable" do
      it "expires" do
        expect(ExpireRequestable).to receive(:call).with(
          requestable:,
          user: a_kind_of(String),
        )
        perform
      end
    end

    context "with requested FI request" do
      let(:requestable) do
        create(:further_information_request, requested_at:, assessment:)
      end

      context "when less than six weeks old" do
        let(:requested_at) { (6.weeks - 1.hour).ago }
        it_behaves_like "not expired requestable"
      end

      context "when it is more than six weeks old" do
        let(:requested_at) { (6.weeks + 1.hour).ago }
        it_behaves_like "expired requestable"
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
              let(:requested_at) { (4.weeks - 1.hour).ago }
              it_behaves_like "not expired requestable"
            end

            context "when it is more than four weeks old from #{country_code}" do
              let(:requested_at) { (4.weeks + 1.hour).ago }
              it_behaves_like "expired requestable"
            end
          end
        end
      end
    end

    context "with any received FI request" do
      let(:requestable) do
        create(
          :further_information_request,
          :received,
          requested_at: 1.year.ago,
        )
      end

      it_behaves_like "not expired requestable"
    end

    context "with any expired FI request" do
      let(:requestable) do
        create(:further_information_request, :expired, requested_at: 1.year.ago)
      end

      it_behaves_like "not expired requestable"
    end

    context "with a requested professional standing request" do
      before do
        application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
      end

      let(:requestable) do
        create(:professional_standing_request, requested_at:, assessment:)
      end

      context "when less than 36 weeks old" do
        let(:requested_at) { (36.weeks - 1.hour).ago }

        it_behaves_like "not expired requestable"
      end

      context "when it is more than 36 weeks old" do
        let(:requested_at) { (36.weeks + 1.hour).ago }

        it_behaves_like "expired requestable"
      end
    end

    context "with any received professional standing request" do
      let(:requestable) do
        create(
          :professional_standing_request,
          :received,
          requested_at: 1.year.ago,
        )
      end

      it_behaves_like "not expired requestable"
    end

    context "with any expired professional standing request" do
      let(:requestable) do
        create(
          :professional_standing_request,
          :expired,
          requested_at: 1.year.ago,
        )
      end

      it_behaves_like "not expired requestable"
    end

    context "with a requested reference request" do
      let(:requestable) { create(:reference_request, requested_at:) }

      context "when less than six weeks old" do
        let(:requested_at) { (6.weeks - 1.hour).ago }

        it_behaves_like "not expired requestable"
      end

      context "when it is more than six weeks old" do
        let(:requested_at) { (6.weeks + 1.hour).ago }

        it_behaves_like "expired requestable"
      end
    end

    context "with any received reference request" do
      let(:requestable) do
        create(:reference_request, :received, requested_at: 1.year.ago)
      end

      it_behaves_like "not expired requestable"
    end

    context "with any expired reference request" do
      let(:requestable) do
        create(:reference_request, :expired, requested_at: 1.year.ago)
      end

      it_behaves_like "not expired requestable"
    end
  end
end
