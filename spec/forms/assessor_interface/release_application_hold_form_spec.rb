# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ReleaseApplicationHoldForm, type: :model do
  subject { described_class.new(application_hold:, user:, release_comment:) }

  let(:application_form) { create(:application_form) }
  let(:application_hold) { create(:application_hold, application_form:) }
  let(:user) { create(:staff) }
  let(:release_comment) { "" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_hold) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:release_comment) }

    context "when application hold has already been released" do
      let(:application_hold) do
        create(:application_hold, application_form:, released_at: Time.current)
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "#save" do
    let(:release_comment) { "Testing." }

    it "releases a hold for application hold" do
      subject.save!

      expect(application_hold.released_at).not_to be_nil
      expect(application_hold.release_comment).to eq("Testing.")
    end
  end
end
