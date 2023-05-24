require "rails_helper"

RSpec.describe DQT::FindTeachersParams do
  describe "#call" do
    let(:application_form) do
      create(
        :application_form,
        date_of_birth: Date.new(1960, 1, 1),
        given_names: "Given",
        family_name: "Family",
      )
    end
    let(:reverse_name) { false }

    subject(:call) { described_class.call(application_form:, reverse_name:) }

    it "returns camel case params" do
      expect(call).to eq(
        { dateOfBirth: "1960-01-01", firstName: "Given", lastName: "Family" },
      )
    end

    context "when reverse_name is true" do
      let(:reverse_name) { true }

      it "returns camel case params with first and last name reversed" do
        expect(call).to eq(
          { dateOfBirth: "1960-01-01", firstName: "Family", lastName: "Given" },
        )
      end
    end
  end
end
