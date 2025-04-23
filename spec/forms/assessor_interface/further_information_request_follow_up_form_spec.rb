# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestFollowUpForm,
               type: :model do
  subject(:form) do
    described_class.for_further_information_request(
      further_information_request,
    ).new(further_information_request:, user:, **params)
  end

  let(:further_information_request) do
    create(:received_further_information_request, :with_items)
  end

  let(:items) { further_information_request.items.order(:created_at) }

  let(:first_item) { items.first }
  let(:third_item) { items.third }

  let(:user) { create(:staff) }

  let(:params) { {} }

  before do
    first_item.review_decision_further_information!
    third_item.review_decision_further_information!
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:further_information_request) }
    it { is_expected.to validate_presence_of(:user) }

    it do
      [first_item, third_item].each do |item|
        expect(subject).to validate_presence_of(
          :"#{item.id}_decision_note",
        ).with_message("Enter instructions for the applicant")
      end
    end
  end

  describe "#save" do
    subject(:form_save) { form.save }

    let(:params) do
      object = {}

      [first_item, third_item].each do |item|
        object["#{item.id}_decision_note"] = "Need more information"
      end

      object
    end

    it "updates the relevant items review decision note" do
      form_save

      expect(first_item.reload.review_decision_note).to eq(
        "Need more information",
      )
      expect(third_item.reload.review_decision_note).to eq(
        "Need more information",
      )
    end
  end

  describe ".initial_attributes" do
    subject(:initial_attributes) do
      described_class.initial_attributes(further_information_request)
    end

    before do
      first_item.update!(review_decision_note: "Testing")
      third_item.update!(review_decision_note: "Testing")
    end

    it "sets the decision notes on all existing further information request items" do
      expect(initial_attributes).to eq(
        {
          "#{first_item.id}_decision_note" => "Testing",
          "#{third_item.id}_decision_note" => "Testing",
          :further_information_request => further_information_request,
        },
      )
    end
  end

  describe ".permittable_parameters" do
    subject(:permittable_parameters) do
      described_class.permittable_parameters(further_information_request)
    end

    it "returns an array of all further information request decision note attributes" do
      expect(permittable_parameters).to contain_exactly(
        "#{first_item.id}_decision_note",
        "#{third_item.id}_decision_note",
      )
    end
  end
end
