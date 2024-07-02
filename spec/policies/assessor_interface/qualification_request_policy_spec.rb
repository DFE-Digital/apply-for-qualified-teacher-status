# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationRequestPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

  describe "#index?" do
    subject(:index?) { policy.index? }

    it_behaves_like "a policy method with permission"
  end

  describe "#index_consent_methods?" do
    subject(:index?) { policy.index_consent_methods? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#check_consent_methods?" do
    subject(:index?) { policy.check_consent_methods? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_unsigned_consent_document?" do
    subject(:update_unsigned_consent_document?) do
      policy.update_unsigned_consent_document?
    end

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_unsigned_consent_document?" do
    subject(:edit_unsigned_consent_document?) do
      policy.edit_unsigned_consent_document?
    end

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#generate_unsigned_consent_document?" do
    subject(:generate_unsigned_consent_document?) do
      policy.generate_unsigned_consent_document?
    end

    it_behaves_like "a policy method requiring the verify permission"
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

    it_behaves_like "a policy method without permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }

    it_behaves_like "a policy method without permission"
  end

  describe "#update_consent_method?" do
    subject(:update?) { policy.update_consent_method? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_consent_method?" do
    subject(:edit?) { policy.edit_consent_method? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_request?" do
    subject(:update_request?) { policy.update_request? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_request?" do
    subject(:edit_request?) { policy.edit_request? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_verify?" do
    subject(:update_verify?) { policy.update_verify? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_verify?" do
    subject(:edit_verify?) { policy.edit_verify? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#update_verify_failed?" do
    subject(:update_verify_failed?) { policy.update_verify_failed? }

    it_behaves_like "a policy method requiring the verify permission"
  end

  describe "#edit_verify_failed?" do
    subject(:edit_verify_failed?) { policy.edit_verify_failed? }

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
