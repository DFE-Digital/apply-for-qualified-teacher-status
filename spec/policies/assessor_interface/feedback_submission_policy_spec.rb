# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FeedbackSubmissionPolicy do
  subject(:policy) { described_class.new(user, nil) }

  it_behaves_like "a policy"

  describe "#index?" do
    subject(:index?) { policy.index? }

    it_behaves_like "a policy method with permission"
  end

  describe "#show?" do
    subject(:show?) { policy.show? }

    it_behaves_like "a policy method with permission"
  end

  describe "#apply_filters?" do
    subject(:apply_filters?) { policy.apply_filters? }

    it_behaves_like "a policy method with permission"
  end

  describe "#clear_filters?" do
    subject(:clear_filters?) { policy.clear_filters? }

    it_behaves_like "a policy method with permission"
  end
end
