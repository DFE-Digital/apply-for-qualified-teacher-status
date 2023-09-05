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
