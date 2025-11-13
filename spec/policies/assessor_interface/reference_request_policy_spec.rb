# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ReferenceRequestPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

  describe "#index?" do
    subject(:index?) { policy.index? }

    it_behaves_like "a policy method with permission"
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

  describe "#update_verify?" do
    subject(:update_verify?) { policy.update_verify? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_verify?" do
    subject(:edit_verify?) { policy.edit_verify? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the change work history and qualification permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_verify_failed?" do
    subject(:update_verify_failed?) { policy.update_verify_failed? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_verify_failed?" do
    subject(:edit_verify?) { policy.edit_verify_failed? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_resend_email?" do
    subject(:resend_email?) { policy.edit_resend_email? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_resend_email?" do
    subject(:resend_email?) { policy.update_resend_email? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#resend_email_confirmation?" do
    subject(:resend_email?) { policy.resend_email_confirmation? }

    it_behaves_like "a policy method requiring the assess permission"
    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#destroy?" do
    subject(:destroy?) { policy.destroy? }

    it_behaves_like "a policy method without permission"
  end
end
