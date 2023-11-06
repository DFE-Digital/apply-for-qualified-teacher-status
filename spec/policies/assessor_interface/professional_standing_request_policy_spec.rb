# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ProfessionalStandingRequestPolicy do
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

  describe "#update_locate?" do
    subject(:update_locate?) { policy.update_locate? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be true }
  end

  describe "#edit_locate?" do
    subject(:edit?) { policy.edit_locate? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be true }
  end

  describe "#update_request?" do
    subject(:update_request?) { policy.update_request? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_request?" do
    subject(:edit_request?) { policy.edit_request? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_verify?" do
    subject(:update_review?) { policy.update_verify? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_verify?" do
    subject(:edit_review?) { policy.edit_verify? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_verify_failed?" do
    subject(:update_verify_failed?) { policy.update_verify_failed? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_verify_failed?" do
    subject(:edit_verify_failed?) { policy.edit_verify_failed? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_review?" do
    subject(:update_review?) { policy.update_review? }
    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#edit_review?" do
    subject(:edit_review?) { policy.edit_review? }
    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    let(:user) { create(:staff, :confirmed) }
    it { is_expected.to be false }
  end
end
