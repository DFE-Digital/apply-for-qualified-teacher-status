# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::WorkHistoryPolicy do
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
    it_behaves_like "a policy method requiring change the work history permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }
    it_behaves_like "a policy method requiring change the work history permission"
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end
end
