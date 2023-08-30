# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotePolicy do
  it_behaves_like "a policy"

  let(:user) { create(:staff, :confirmed) }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  describe "#index?" do
    subject(:index?) { policy.index? }
    it { is_expected.to be true }
  end

  describe "#show?" do
    subject(:show?) { policy.show? }
    it { is_expected.to be true }
  end

  describe "#create?" do
    subject(:create?) { policy.create? }
    it { is_expected.to be true }
  end

  describe "#new?" do
    subject(:new?) { policy.new? }
    it { is_expected.to be true }
  end

  describe "#update?" do
    subject(:update?) { policy.update? }
    it { is_expected.to be true }
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }
    it { is_expected.to be true }
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }
    it { is_expected.to be false }
  end
end
