# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::RequestableForm, type: :model do
  let(:requestable) { create(:reference_request, :received) }
  let(:passed) { nil }

  subject(:form) { described_class.new(requestable:, passed:) }

  describe "save" do
    context "when passed is nil" do
      it "fails validation" do
        expect(form.save).to be false

        expect(form.errors).to have_key(:passed)
      end
    end

    context "when passed is true" do
      let(:passed) { true }

      it "updates passed field" do
        expect { form.save }.to change(requestable, :passed).from(nil).to(true)
      end

      it "sets reviewed at" do
        freeze_time do
          expect { form.save }.to change(requestable, :reviewed_at).from(
            nil,
          ).to(Time.zone.now)
        end
      end
    end

    context "when passed is false" do
      let(:passed) { false }

      it "updates passed field" do
        expect { form.save }.to change(requestable, :passed).from(nil).to(false)
      end

      it "sets reviewed at" do
        freeze_time do
          expect { form.save }.to change(requestable, :reviewed_at).from(
            nil,
          ).to(Time.zone.now)
        end
      end
    end
  end
end
