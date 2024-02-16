# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationRequestPolicy do
  it_behaves_like "a policy"

  let(:user) { nil }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  describe "#index?" do
    subject(:index?) { policy.index? }
    it_behaves_like "a policy method with permission"
  end

  describe "#show?" do
    subject(:show?) { policy.show? }
    it_behaves_like "a policy method without permission"
  end

  describe "#consent_letter?" do
    subject(:consent_letter?) { policy.consent_letter? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#create?" do
    subject(:create?) { policy.create? }
    it_behaves_like "a policy method without permission"
  end

  describe "#new?" do
    subject(:new?) { policy.new? }
    it_behaves_like "a policy method without permission"
  end

  describe "#update?" do
    subject(:update?) { policy.update? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }
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
    it_behaves_like "a policy method without permission"
  end
end
