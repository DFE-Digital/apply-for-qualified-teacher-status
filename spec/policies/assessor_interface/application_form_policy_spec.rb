# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormPolicy do
  it_behaves_like "a policy"

  let(:user) { nil }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  describe "#index?" do
    subject(:index?) { policy.index? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be true }
  end

  describe "#show?" do
    subject(:show?) { policy.show? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be true }
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

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    let(:record) { create(:assessment, :award) }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_withdraw_permission) }
      it { is_expected.to be true }
    end
  end

  describe "#withdraw?" do
    subject(:rollback?) { policy.withdraw? }

    let(:record) { create(:assessment, :award) }

    context "without permission" do
      let(:user) { create(:staff, :confirmed) }
      it { is_expected.to be false }
    end

    context "with permission" do
      let(:user) { create(:staff, :confirmed, :with_withdraw_permission) }
      it { is_expected.to be true }
    end
  end
end
