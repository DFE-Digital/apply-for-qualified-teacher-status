# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestReviewForm,
               type: :model do
  subject(:form) do
    described_class.for_further_information_request(
      further_information_request,
    ).new(further_information_request:, user:, **params)
  end

  let(:further_information_request) do
    create(:received_further_information_request, :with_items)
  end
  let(:user) { create(:staff) }

  let(:params) { {} }

  describe "validations" do
    it { is_expected.to validate_presence_of(:further_information_request) }
    it { is_expected.to validate_presence_of(:user) }

    it do
      further_information_request.items.each do |item|
        expect(subject).to validate_presence_of(
          :"#{item.id}_decision",
        ).with_message(
          "Select how you would like to respond to the applicant’s information",
        )
      end
    end
  end

  describe "#save" do
    subject(:form_save) { form.save }

    context "when all items are accepted" do
      let(:params) do
        object = {}

        further_information_request.items.each do |item|
          object["#{item.id}_decision"] = "accept"
        end

        object
      end

      it "updates the items review_decision" do
        form_save

        expect(
          further_information_request.items.reload.first,
        ).to be_review_decision_accept
        expect(
          further_information_request.items.reload.second,
        ).to be_review_decision_accept
        expect(
          further_information_request.items.reload.last,
        ).to be_review_decision_accept
      end

      it "updates review passed field" do
        expect { form_save }.to change(
          further_information_request,
          :review_passed,
        ).from(nil).to(true)
      end

      it "does not update review note field" do
        expect { form_save }.not_to change(
          further_information_request,
          :review_note,
        )
      end

      it "sets reviewed at" do
        freeze_time do
          expect { form_save }.to change(
            further_information_request,
            :reviewed_at,
          ).from(nil).to(Time.zone.now)
        end
      end
    end

    context "when some items are declined and some accepted" do
      let(:params) do
        object = {}

        object[
          "#{further_information_request.items.first.id}_decision"
        ] = "decline"
        object[
          "#{further_information_request.items.second.id}_decision"
        ] = "accept"
        object[
          "#{further_information_request.items.last.id}_decision"
        ] = "accept"

        object
      end

      it "updates the items review_decision" do
        form_save

        expect(
          further_information_request.items.reload.first,
        ).to be_review_decision_decline
        expect(
          further_information_request.items.reload.second,
        ).to be_review_decision_accept
        expect(
          further_information_request.items.reload.last,
        ).to be_review_decision_accept
      end

      it "does not update review passed field" do
        expect { form_save }.not_to change(
          further_information_request,
          :review_passed,
        )
      end

      it "does not update review note field" do
        expect { form_save }.not_to change(
          further_information_request,
          :review_note,
        )
      end

      it "does not set reviewed at" do
        freeze_time do
          expect { form_save }.not_to change(
            further_information_request,
            :reviewed_at,
          )
        end
      end
    end

    context "when all items are declined" do
      let(:params) do
        object = {}

        further_information_request.items.each do |item|
          object["#{item.id}_decision"] = "decline"
        end

        object
      end

      it "updates the items review_decision" do
        form_save

        expect(
          further_information_request.items.reload.first,
        ).to be_review_decision_decline
        expect(
          further_information_request.items.reload.second,
        ).to be_review_decision_decline
        expect(
          further_information_request.items.reload.last,
        ).to be_review_decision_decline
      end

      it "does not update review passed field" do
        expect { form_save }.not_to change(
          further_information_request,
          :review_passed,
        )
      end

      it "does not update review note field" do
        expect { form_save }.not_to change(
          further_information_request,
          :review_note,
        )
      end

      it "does not set reviewed at" do
        freeze_time do
          expect { form_save }.not_to change(
            further_information_request,
            :reviewed_at,
          )
        end
      end
    end
  end

  describe "#all_further_information_request_items_accepted?" do
    subject(:all_further_information_request_items_accepted?) do
      form.all_further_information_request_items_accepted?
    end

    before { form.save }

    context "when all items are accepted" do
      let(:params) do
        object = {}

        further_information_request.items.each do |item|
          object["#{item.id}_decision"] = "accept"
        end

        object
      end

      it "returns true" do
        expect(all_further_information_request_items_accepted?).to be true
      end
    end

    context "when some items are declined and some accepted" do
      let(:params) do
        object = {}

        object[
          "#{further_information_request.items.first.id}_decision"
        ] = "decline"
        object[
          "#{further_information_request.items.second.id}_decision"
        ] = "accept"
        object[
          "#{further_information_request.items.last.id}_decision"
        ] = "accept"

        object
      end

      it "returns false" do
        expect(all_further_information_request_items_accepted?).to be false
      end
    end

    context "when all items are declined" do
      let(:params) do
        object = {}

        further_information_request.items.each do |item|
          object["#{item.id}_decision"] = "decline"
        end

        object
      end

      it "returns false" do
        expect(all_further_information_request_items_accepted?).to be false
      end
    end
  end

  describe ".initial_attributes" do
    subject(:initial_attributes) do
      described_class.initial_attributes(further_information_request)
    end

    before do
      further_information_request.items.update_all(review_decision: "accept")
    end

    it "sets the decision on all existing further information request items" do
      expect(initial_attributes).to eq(
        {
          "#{further_information_request.items.first.id}_decision" => "accept",
          "#{further_information_request.items.second.id}_decision" => "accept",
          "#{further_information_request.items.third.id}_decision" => "accept",
          :further_information_request => further_information_request,
        },
      )
    end
  end

  describe ".permittable_parameters" do
    subject(:permittable_parameters) do
      described_class.permittable_parameters(further_information_request)
    end

    it "returns an array of all further information request decision attributes" do
      expect(permittable_parameters).to contain_exactly(
        "#{further_information_request.items.first.id}_decision",
        "#{further_information_request.items.second.id}_decision",
        "#{further_information_request.items.last.id}_decision",
      )
    end
  end
end
