# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestConfirmFollowUpForm,
               type: :model do
  subject(:form) { described_class.new(further_information_request:, user:) }

  let(:further_information_request) do
    create(:received_further_information_request, :with_items)
  end

  let(:user) { create(:staff) }

  describe "#save" do
    subject(:save) { form.save }

    it "updates review passed field" do
      expect { save }.to change(
        further_information_request,
        :review_passed,
      ).from(nil).to(false)
    end

    it "updates review note field" do
      expect { save }.to change(further_information_request, :review_note).from(
        "",
      ).to("Further information requested")
    end

    it "sets reviewed at" do
      freeze_time do
        expect { save }.to change(
          further_information_request,
          :reviewed_at,
        ).from(nil).to(Time.zone.now)
      end
    end

    it "generates a new further information request for assessment" do
      expect { save }.to change(
        further_information_request.assessment.further_information_requests,
        :count,
      ).from(1).to(2)
    end
  end
end
