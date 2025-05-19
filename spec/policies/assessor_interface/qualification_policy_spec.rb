# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { nil }
  let(:user) { nil }

  it_behaves_like "a policy"

  describe "#update?" do
    subject(:update?) { policy.update? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end

  describe "#edit?" do
    subject(:edit?) { policy.edit? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end

  describe "#edit_assign_teaching?" do
    subject(:edit_assign_teaching?) { policy.edit_assign_teaching? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end

  describe "#update_assign_teaching?" do
    subject(:update_assign_teaching?) { policy.update_assign_teaching? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end

  describe "#invalid_country?" do
    subject(:invalid_country?) { policy.invalid_country? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end

  describe "#invalid_work_duration?" do
    subject(:invalid_work_duration?) { policy.invalid_work_duration? }

    it_behaves_like "a policy method requiring the change work history and qualification permission"
  end
end
