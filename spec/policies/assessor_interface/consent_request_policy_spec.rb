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
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#new?" do
    subject(:new?) { policy.new? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update?" do
    subject(:update?) { policy.update? }
    it_behaves_like "a policy method without permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }
    it_behaves_like "a policy method without permission"
  end

  describe "#update_upload?" do
    subject(:update_upload?) { policy.update_upload? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_upload?" do
    subject(:edit_upload?) { policy.edit_upload? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#check_upload?" do
    subject(:check_upload?) { policy.check_upload? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_request?" do
    subject(:update?) { policy.update_request? }
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_request?" do
    subject(:edit?) { policy.edit_request? }
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
