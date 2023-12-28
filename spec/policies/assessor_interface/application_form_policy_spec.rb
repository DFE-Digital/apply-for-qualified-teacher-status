# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormPolicy do
  it_behaves_like "a policy"

  let(:user) { nil }
  let(:record) { nil }

  subject(:policy) { described_class.new(user, record) }

  describe "#index?" do
    subject(:index?) { policy.index? }
    it_behaves_like "a policy method with permission"
  end

  describe "#apply_filters?" do
    subject(:apply_filters?) { policy.apply_filters? }
    it_behaves_like "a policy method with permission"
  end

  describe "#clear_filters?" do
    subject(:clear_filter?) { policy.clear_filters? }
    it_behaves_like "a policy method with permission"
  end

  describe "#show?" do
    subject(:show?) { policy.show? }
    it_behaves_like "a policy method with permission"
  end

  describe "#status?" do
    subject(:status?) { policy.status? }
    it_behaves_like "a policy method with permission"
  end

  describe "#timeline?" do
    subject(:timeline?) { policy.timeline? }
    it_behaves_like "a policy method with permission"
  end

  describe "#show_pdf?" do
    subject(:show_pdf?) { policy.show_pdf? }
    it_behaves_like "a policy method with permission"
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
    it_behaves_like "a policy method without permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }
    it_behaves_like "a policy method requiring the change name permission"
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }
    it_behaves_like "a policy method requiring the withdraw permission"
  end

  describe "#withdraw?" do
    subject(:rollback?) { policy.withdraw? }
    it_behaves_like "a policy method requiring the withdraw permission"
  end
end
