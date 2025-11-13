# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::EligibilityDomainPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

  describe "#index?" do
    subject(:index?) { policy.index? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

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

  describe "#applications?" do
    subject(:applications?) { policy.applications? }

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

  describe "#update_archive?" do
    subject(:update_archive?) { policy.update_archive? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_archive?" do
    subject(:edit_archive?) { policy.edit_archive? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_reactivate?" do
    subject(:update?) { policy.update_reactivate? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_reactivate?" do
    subject(:edit?) { policy.edit_reactivate? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end
end
