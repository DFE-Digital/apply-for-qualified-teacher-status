# frozen_string_literal: true

RSpec.shared_examples "a policy" do
  let(:user) { nil }

  subject(:policy) { described_class.new(user, nil) }

  it "must have a user" do
    expect { policy }.to raise_error(Pundit::NotAuthorizedError)
  end

  context "with a user" do
    let(:user) { create(:staff, :confirmed) }

    it { is_expected.to_not be_nil }
  end
end

RSpec.shared_examples "a policy method requiring the award decline permission" do
  context "without permission" do
    let(:user) { create(:staff) }
    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_award_decline_permission) }
    it { is_expected.to be true }
  end
end

RSpec.shared_examples "a policy method requiring the change name permission" do
  context "without permission" do
    let(:user) { create(:staff) }
    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_change_name_permission) }
    it { is_expected.to be true }
  end
end

RSpec.shared_examples "a policy method requiring change the work history permission" do
  context "without permission" do
    let(:user) { create(:staff) }
    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_change_work_history_permission) }
    it { is_expected.to be true }
  end
end

RSpec.shared_examples "a policy method requiring the reverse decision permission" do
  context "without permission" do
    let(:user) { create(:staff) }
    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_reverse_decision_permission) }
    it { is_expected.to be true }
  end
end

RSpec.shared_examples "a policy method requiring the withdraw permission" do
  context "without permission" do
    let(:user) { create(:staff) }
    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_withdraw_permission) }
    it { is_expected.to be true }
  end
end

RSpec.shared_examples "a policy method requiring the support console permission" do
  context "without permission" do
    let(:user) { create(:staff) }
    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_support_console_permission) }
    it { is_expected.to be true }
  end
end