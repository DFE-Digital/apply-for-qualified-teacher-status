require "rails_helper"

RSpec.describe TeacherInterface::FurtherInformationRequestItemTextForm,
               type: :model do
  subject(:form) do
    described_class.new(further_information_request_item:, response:)
  end

  let(:further_information_request_item) do
    build(:further_information_request_item)
  end
  let(:response) { nil }

  it { is_expected.to validate_presence_of(:further_information_request_item) }
  it { is_expected.to validate_presence_of(:response) }

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a blank value" do
      let(:response) { "" }

      it { is_expected.to be false }
    end

    context "with a present value" do
      let(:response) { "response" }

      it { is_expected.to be true }
    end
  end

  describe "#update_model" do
    subject(:response) { further_information_request_item.response }

    before { form.update_model }

    context "with a blank value" do
      let(:response) { "" }

      it { is_expected.to eq("") }
    end

    context "with a present value" do
      let(:response) { "response" }

      it { is_expected.to eq("response") }
    end
  end
end
