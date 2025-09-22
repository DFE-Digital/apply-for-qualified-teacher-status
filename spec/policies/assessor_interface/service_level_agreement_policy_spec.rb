# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ServiceLevelAgreementPolicy do
  it_behaves_like "a policy"

  describe "#index?" do
    subject(:index?) { described_class.new(user, nil).index? }

    it_behaves_like "a policy method requiring the manage staff permission"
  end
end
