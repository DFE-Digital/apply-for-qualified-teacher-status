# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorPolicy do
  it_behaves_like "a policy"

  let(:user) { create(:staff, :confirmed) }

  subject(:policy) { described_class.new(user, nil) }

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
    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#new?" do
    subject(:new?) { policy.new? }
    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#update?" do
    subject(:update?) { policy.update? }
    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }
    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }
    it_behaves_like "a policy method requiring the assess permission"
  end
end
