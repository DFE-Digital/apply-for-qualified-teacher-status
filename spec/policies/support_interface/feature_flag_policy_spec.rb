# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::FeatureFlagPolicy do
  it_behaves_like "a policy"

  describe "#index?" do
    subject(:index?) { described_class.new(user, nil).index? }

    it_behaves_like "a policy method requiring the support console permission"
  end

  describe "#activate?" do
    subject(:activate?) { described_class.new(user, nil).activate? }

    it_behaves_like "a policy method requiring the support console permission"
  end

  describe "#deactivate?" do
    subject(:deactivate?) { described_class.new(user, nil).deactivate? }

    it_behaves_like "a policy method requiring the support console permission"
  end
end
