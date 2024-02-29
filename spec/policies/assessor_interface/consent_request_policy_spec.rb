# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ConsentRequestPolicy do
  it_behaves_like "a policy"

  let(:user) { nil }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  describe "#index?" do
    subject(:index?) { policy.index? }
    it_behaves_like "a policy method without permission"
  end

  describe "#show?" do
    subject(:show?) { policy.show? }
    it_behaves_like "a policy method without permission"
  end

  describe "#create?" do
    subject(:create?) { policy.create? }
    it_behaves_like "a policy method without permission"
  end

  describe "#new?" do
    subject(:new?) { policy.new? }
    it_behaves_like "a policy method without permission"
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
