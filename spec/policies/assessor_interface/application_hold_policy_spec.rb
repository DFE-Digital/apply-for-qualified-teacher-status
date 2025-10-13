# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationHoldPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

  describe "#create?" do
    subject(:create?) { policy.create? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#new?" do
    subject(:new?) { policy.new? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#new_submit?" do
    subject(:new_submit?) { policy.new_submit? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#new_confirm?" do
    subject(:new_confirm?) { policy.new_confirm? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update?" do
    subject(:update?) { policy.update? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_submit?" do
    subject(:edit_submit?) { policy.edit_submit? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_confirm?" do
    subject(:edit_confirm?) { policy.edit_confirm? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#confirmation?" do
    subject(:confirmation?) { policy.confirmation? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end
end
