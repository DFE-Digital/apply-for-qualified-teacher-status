# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateDQTMatchJob do
  describe "#perform" do
    let(:application_form) do
      create(:application_form, :submitted, :with_personal_information)
    end

    subject(:perform) { described_class.new.perform(application_form) }

    before { allow(DQT::Client::FindTeachers).to receive(:call).and_return([]) }

    it "searches DQT for teachers" do
      expect(DQT::Client::FindTeachers).to receive(:call).with(
        application_form:,
      )

      expect(DQT::Client::FindTeachers).to receive(:call).with(
        application_form:,
        reverse_name: true,
      )

      perform
    end

    it "does not update the application form if no results are returned" do
      expect { perform }.to change(application_form, :dqt_match).to(
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

      expect(DQT::Client::FindTeachers).to receive(:call).with(
        application_form:,
      ).and_return(results)

      expect { perform }.to change(application_form, :dqt_match).to(
        { "teachers" => results },
      )
    end
  end
end
