# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorPolicy do
  it_behaves_like "a policy"

  let(:user) { nil }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  describe "#index?" do
    subject(:index?) { policy.index? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be true }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_award_decline_permission) }
      it { is_expected.to be true }
    end
  end

  describe "#show?" do
    subject(:show?) { policy.show? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be true }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_award_decline_permission) }
      it { is_expected.to be true }
    end
  end

  describe "#create?" do
    subject(:create?) { policy.create? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_award_decline_permission) }
      it { is_expected.to be true }
    end
  end

  describe "#new?" do
    subject(:new?) { policy.new? }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_award_decline_permission) }
      it { is_expected.to be true }
    end
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
      let(:user) { create(:staff, :confirmed, :with_award_decline_permission) }
      it { is_expected.to be true }
    end
  end
end
