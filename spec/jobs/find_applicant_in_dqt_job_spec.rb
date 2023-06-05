# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindApplicantInDQTJob do
  describe "#perform" do
    let(:application_form) do
      create(:application_form, :submitted, :with_personal_information)
    end
    let(:application_form_id) { application_form.id }

    subject(:perform) { described_class.perform_now(application_form_id:) }

    it "calls the FindTeachersInDQT service" do
      expect(FindTeachersInDQT).to receive(:call).with(
        application_form:,
        reverse_name: true,
      ).and_return([])

      perform
    end

    it "does not update the application form if no results are returned" do
      allow(FindTeachersInDQT).to receive(:call).with(
        application_form:,
        reverse_name: true,
      ).and_return([])

      perform

      expect(application_form.reload.dqt_match).to eq({})
    end

    it "updates the application form with the TRN" do
      result = {
        date_of_birth: application_form.date_of_birth.iso8601.to_s,
        first_name: "Jane",
        last_name: "Smith",
        trn: "1234567",
      }

      allow(FindTeachersInDQT).to receive(:call).and_return(
        [
          result,
          {
            date_of_birth: "1980-01-01",
            first_name: "Janet",
            last_name: "Jones",
            trn: "7654321",
          },
        ],
      )

      perform

      expect(application_form.reload.dqt_match).to eq(result.as_json)
    end
  end
end
