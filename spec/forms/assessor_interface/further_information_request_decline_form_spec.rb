# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestDeclineForm,
               type: :model do
  subject(:form) do
    described_class.new(further_information_request:, user:, note:)
  end

  let(:further_information_request) do
    create(:received_further_information_request)
  end
  let(:user) { create(:staff) }
  let(:note) { "" }

  describe "validations" do
    it { is_expected.to allow_values(true, false).for(:note) }
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:note) { "Note." }

    it "updates review passed field" do
      expect { save }.to change(
        further_information_request,
        :review_passed,
      ).from(nil).to(false)
    end

    it "updates review note field" do
      expect { save }.to change(further_information_request, :review_note).from(
        "",
      ).to("Note.")
    end

    it "sets reviewed at" do
      freeze_time do
        expect { save }.to change(
          further_information_request,
          :reviewed_at,
        ).from(nil).to(Time.zone.now)
      end
    end
  end
end
