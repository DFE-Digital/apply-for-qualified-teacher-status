# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::DecisionReviewRequestPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

  describe "#edit?" do
    subject(:edit?) { policy.edit? }

    it_behaves_like "a policy method with permission"
  end

  describe "#update?" do
    subject(:update?) { policy.update? }

    it_behaves_like "a policy method requiring the reverse decision permission"
  end

  describe "#edit_confirm?" do
    subject(:edit_confirm?) { policy.edit_confirm? }

    it_behaves_like "a policy method requiring the reverse decision permission"
  end

  describe "#update_confirm?" do
    subject(:update_confirm?) { policy.update_confirm? }

    it_behaves_like "a policy method requiring the reverse decision permission"
  end

  describe "#confirmation?" do
    subject(:confirmation?) { policy.confirmation? }

    it_behaves_like "a policy method requiring the reverse decision permission"
  end
end
