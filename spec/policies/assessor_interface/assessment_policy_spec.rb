# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentPolicy do
  it_behaves_like "a policy"

  let(:user) { nil }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  describe "#index?" do
    subject(:index?) { policy.index? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end

  describe "#show?" do
    subject(:show?) { policy.show? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end

  describe "#create?" do
    subject(:create?) { policy.create? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end

  describe "#new?" do
    subject(:new?) { policy.new? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end

  describe "#update?" do
    subject(:update?) { policy.update? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_award_decline_permission) }
      it { is_expected.to be true }
    end
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_award_decline_permission) }
      it { is_expected.to be true }
    end
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) do
        create(:staff, :confirmed, :with_reverse_decision_permission)
      end
      it { is_expected.to be true }
    end
  end

  describe "#rollback?" do
    subject(:rollback?) { policy.rollback? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) do
        create(:staff, :confirmed, :with_reverse_decision_permission)
      end
      it { is_expected.to be true }
    end
  end
end
