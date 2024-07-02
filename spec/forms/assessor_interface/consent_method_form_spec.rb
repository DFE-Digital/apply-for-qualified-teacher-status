# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ConsentMethodForm, type: :model do
  subject(:form) do
    described_class.new(qualification_request:, consent_method:)
  end

  let(:qualification) { create(:qualification) }
  let(:qualification_request) { create(:qualification_request, qualification:) }
  let(:consent_method) { "unsigned" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:qualification_request) }
    it { is_expected.to validate_presence_of(:consent_method) }

    it do
      expect(subject).to validate_inclusion_of(:consent_method).in_array(
        %w[signed_ecctis signed_institution unsigned none],
      )
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    it "sets the consent method" do
      expect { save }.to change(qualification_request, :consent_method).to(
        "unsigned",
      )
    end

    context "when a consent request already exists" do
      before { create(:consent_request, qualification:) }

      context "and the consent method is unsigned" do
        let(:consent_method) { %w[unsigned none].sample }

        it "deletes the consent request" do
          expect { save }.to change {
            ConsentRequest.where(qualification:).count
          }.from(1).to(0)
        end
      end

      context "and the consent method is signed" do
        let(:consent_method) { %w[signed_ecctis signed_institution].sample }

        it "doesn't delete the consent request" do
          expect { save }.not_to change {
            ConsentRequest.where(qualification:).count
          }.from(1)
        end
      end
    end
  end
end
