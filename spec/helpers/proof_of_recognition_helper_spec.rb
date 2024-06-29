# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProofOfRecognitionHelper do
  let(:region) do
    double(
      name: "Region Name",
      status_check_written?: status,
      status_check_online?: status,
      sanction_check_written?: sanction,
      sanction_check_online?: sanction,
      application_form_skip_work_history:,
      teaching_authority_name: "teaching authority",
      teaching_authority_certificate: "letter",
    )
  end

  let(:status) { false }
  let(:sanction) { false }
  let(:application_form_skip_work_history) { false }

  describe "proof_of_recognition_requirements_for" do
    subject { proof_of_recognition_requirements_for(region:) }

    context "with only a written status" do
      let(:status) { true }

      it do
        expect(subject).to contain_exactly(
          "that you’ve completed a teaching qualification/teacher training",
          "that you’ve successfully completed any period of professional experience comparable to an induction " \
            "period (if required)",
          "the age ranges and subjects you’re qualified to teach",
          "that you’re qualified to teach at state or government schools",
        )
      end
    end

    context "with only a written sanction" do
      let(:sanction) { true }

      it do
        expect(subject).to contain_exactly(
          "suspended",
          "barred",
          "cancelled",
          "revoked",
          "restricted or subject to sanctions",
        )
      end
    end

    context "with a written sanction and a written status" do
      let(:sanction) { true }
      let(:status) { true }

      it do
        expect(subject).to contain_exactly(
          "that you’ve completed a teaching qualification/teacher training",
          "that you’ve successfully completed any period of professional experience comparable to an induction " \
            "period (if required)",
          "that your authorisation to teach has never been suspended, barred, cancelled, revoked or restricted," \
            " and that you have no sanctions against you",
          "the age ranges and subjects you’re qualified to teach",
          "that you’re qualified to teach at state or government schools",
        )
      end
    end

    context "with a country where the region skips work history" do
      let(:sanction) { true }
      let(:application_form_skip_work_history) { true }

      it do
        expect(subject).to contain_exactly(
          "if you have completed your induction in Region Name",
        )
      end
    end
  end

  describe "#proof_of_recognition_description_for" do
    subject { proof_of_recognition_description_for(region:) }

    context "with only a written status" do
      let(:status) { true }

      it do
        expect(subject).to eq(
          "In the letter the teaching authority must confirm:",
        )
      end
    end

    context "with only a written sanction" do
      let(:sanction) { true }

      it do
        expect(subject).to eq(
          "In the letter the teaching authority must confirm that your authorisation to teach has never been:",
        )
      end
    end

    context "with a written sanction and a written status" do
      let(:sanction) { true }
      let(:status) { true }

      it do
        expect(subject).to eq(
          "In the letter the teaching authority must confirm:",
        )
      end
    end
  end
end
