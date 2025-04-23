# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

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

    it_behaves_like "a policy method with permission"
  end

  describe "#edit_decline?" do
    subject(:edit_decline?) { policy.edit_decline? }

    it_behaves_like "a policy method with permission"
  end

  describe "#update_decline?" do
    subject(:update_decline?) { policy.update_decline? }

    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#edit_follow_up?" do
    subject(:edit_follow_up?) { policy.edit_follow_up? }

    it_behaves_like "a policy method with permission"
  end

  describe "#update_follow_up?" do
    subject(:update_follow_up?) { policy.update_follow_up? }

    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#edit_confirm_follow_up?" do
    subject(:edit_confirm_follow_up?) { policy.edit_confirm_follow_up? }

    it_behaves_like "a policy method with permission"
  end

  describe "#update_confirm_follow_up?" do
    subject(:update_confirm_follow_up?) { policy.update_confirm_follow_up? }

    it_behaves_like "a policy method requiring the assess permission"
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    it_behaves_like "a policy method without permission"
  end
end
