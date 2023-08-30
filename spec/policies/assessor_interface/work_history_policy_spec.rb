# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::WorkHistoryPolicy do
  let(:user) { nil }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  it "must have a user" do
    expect { policy }.to raise_error(Pundit::NotAuthorizedError)
  end

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
      let(:user) do
        create(:staff, :confirmed, :with_change_work_history_permission)
      end
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
      let(:user) do
        create(:staff, :confirmed, :with_change_work_history_permission)
      end
      it { is_expected.to be true }
    end
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end
end
