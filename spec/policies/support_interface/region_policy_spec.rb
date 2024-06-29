# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::RegionPolicy do
  it_behaves_like "a policy"

  describe "#edit?" do
    subject(:edit?) { described_class.new(user, nil).edit? }

    it_behaves_like "a policy method requiring the support console permission"
  end

  describe "#update?" do
    subject(:update?) { described_class.new(user, nil).update? }

    it_behaves_like "a policy method requiring the support console permission"
  end

  describe "#preview?" do
    subject(:preview?) { described_class.new(user, nil).preview? }

    it_behaves_like "a policy method requiring the support console permission"
  end
end
