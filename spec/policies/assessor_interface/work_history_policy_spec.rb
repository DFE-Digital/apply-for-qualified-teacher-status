# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::WorkHistoryPolicy do
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

    it_behaves_like "a policy method without permission"
  end

  describe "#new?" do
    subject(:new?) { policy.new? }

    it_behaves_like "a policy method without permission"
  end

  describe "#update?" do
    subject(:update?) { policy.update? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    it_behaves_like "a policy method without permission"
  end
end
