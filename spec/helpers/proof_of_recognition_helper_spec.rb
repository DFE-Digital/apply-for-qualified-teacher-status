require "rails_helper"

RSpec.describe ProofOfRecognitionHelper do
  let(:region) do
    double(
      status_check_written?: status,
      sanction_check_written?: sanction,
      country:
        double(
          teaching_authority_checks_sanctions?:
            teaching_authority_checks_sanctions,
        ),
    )
  end
  let(:status) { false }
  let(:sanction) { false }
  let(:teaching_authority_checks_sanctions) { true }

  describe "proof_of_recognition_requirements_for" do
    subject { proof_of_recognition_requirements_for(region:) }

    context "written status only" do
      let(:status) { true }

      it do
        is_expected.to match_array(
          [
            "that you've completed a teaching qualification/teacher training",
            "that you’ve successfully completed any period of professional experience " \
              "comparable to an induction period (if required)",
            "the age ranges and subjects you’re qualified to teach",
          ],
        )
      end
    end

    context "written sanction only" do
      let(:sanction) { true }

      it do
        is_expected.to match_array(
          [
            "that your authorisation to teach has never been suspended, barred, " \
              "cancelled, revoked or restricted, and that you have no sanctions against you",
          ],
        )
      end
    end

    context "both" do
      let(:sanction) { true }
      let(:status) { true }

      it do
        is_expected.to match_array(
          [
            "that you've completed a teaching qualification/teacher training",
            "that you’ve successfully completed any period of professional experience comparable " \
              "to an induction period (if required)",
            "that your authorisation to teach has never been suspended, barred, cancelled, " \
              "revoked or restricted, and that you have no sanctions against you",
            "the age ranges and subjects you’re qualified to teach",
            "that you’re qualified to teach at state or government schools",
          ],
        )
      end
    end

    context "with a country where authority doesn't change sanctions" do
      let(:sanction) { true }
      let(:teaching_authority_checks_sanctions) { false }

      it { is_expected.to be_empty }
    end
  end

  describe "proof_of_recognition_description_for" do
    subject { proof_of_recognition_description_for(region:) }

    context "written status only" do
      let(:status) { true }

      it do
        is_expected.to eq(
          "The authority or territory that recognises you as a teacher must confirm:",
        )
      end
    end

    context "written sanction only" do
      let(:sanction) { true }

      it do
        is_expected.to eq(
          "The education department or authority must also confirm in writing:",
        )
      end
    end

    context "both" do
      let(:sanction) { true }
      let(:status) { true }

      it do
        is_expected.to eq(
          "The authority or territory that recognises you as a teacher must confirm:",
        )
      end
    end
  end
end
