# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindTeachersInDQT do
  describe "#call" do
    let(:application_form) do
      create(:application_form, :submitted, :with_personal_information)
    end
    let(:results) { [] }

    subject(:call) do
      described_class.call(application_form:, reverse_name: true)
    end

    it "calls the Find Teachers DQT API service" do
      expect(DQT::Client::FindTeachers).to receive(:call).with(
        application_form:,
      ).and_return(results)
      expect(DQT::Client::FindTeachers).to receive(:call).with(
        application_form:,
        reverse_name: true,
      ).and_return(results)

      expect(call).to eq([])
    end

    context "with results in the API response" do
      let(:results) do
        [
          {
            date_of_birth: application_form.date_of_birth.iso8601.to_s,
            first_name: application_form.given_names,
            last_name: application_form.family_name,
            trn: "1234567",
          },
        ]
      end
      before do
        allow(DQT::Client::FindTeachers).to receive(:call).and_return(results)
      end

      it "returns the results" do
        expect(call).to eq(results)
      end
    end
  end
end
