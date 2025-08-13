# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::PrioritisationReferenceRequestPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

  describe "#index?" do
    subject(:index?) { policy.index? }

    it_behaves_like "a policy method with permission"
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

  describe "#confirmation?" do
    subject(:confirmation?) { policy.confirmation? }

    it_behaves_like "a policy method with permission"
  end
end
