# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateTRSMatchJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(application_form) }

    let(:application_form) do
      create(:application_form, :submitted, :with_personal_information)
    end

    before { allow(TRS::Client::FindTeachers).to receive(:call).and_return([]) }

    it "searches TRS for teachers" do
      expect(TRS::Client::FindTeachers).to receive(:call).with(
        application_form:,
      )

      expect(TRS::Client::FindTeachers).to receive(:call).with(
        application_form:,
        reverse_name: true,
      )

      perform
    end

    it "does not update the application form if no results are returned" do
      expect { perform }.to change(application_form, :trs_match).to(
        { "teachers" => [] },
      )
    end

    it "updates the application form with the TRN" do
      results = [
        {
          "date_of_birth" => application_form.date_of_birth.iso8601.to_s,
          "first_name" => "Jane",
          "last_name" => "Smith",
          "trn" => "1234567",
        },
        {
          "date_of_birth" => "1980-01-01",
          "first_name" => "Janet",
          "last_name" => "Jones",
          "trn" => "7654321",
        },
      ]

      allow(TRS::Client::FindTeachers).to receive(:call).with(
        application_form:,
      ).and_return(results)

      expect { perform }.to change(application_form, :trs_match).to(
        { "teachers" => results },
      )
    end

    context "when draft" do
      let(:application_form) { create(:application_form, :draft) }

      it "doesn't search TRS for teachers" do
        expect(TRS::Client::FindTeachers).not_to receive(:call)

        perform
      end
    end

    context "when completed" do
      let(:application_form) { create(:application_form, :awarded) }

      it "doesn't search TRS for teachers" do
        expect(TRS::Client::FindTeachers).not_to receive(:call)

        perform
      end
    end
  end
end
