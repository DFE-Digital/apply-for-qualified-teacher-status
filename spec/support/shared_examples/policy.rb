# frozen_string_literal: true

RSpec.shared_examples "a policy" do
  subject(:policy) { described_class.new(user, nil) }

  let(:user) { nil }

  it "must have a user" do
    expect { policy }.to raise_error(Pundit::NotAuthorizedError)
  end

  context "with a user" do
    let(:user) { create(:staff) }

    it { is_expected.not_to be_nil }
  end
end

RSpec.shared_examples "a policy method with permission" do
  let(:user) { create(:staff) }
  it { is_expected.to be true }

  context "when staff is archived" do
    let(:user) { create(:staff, archived: true) }

    it { is_expected.to be false }
  end
end

RSpec.shared_examples "a policy method without permission" do
  let(:user) { create(:staff) }
  it { is_expected.to be false }
end

RSpec.shared_examples "a policy method requiring the assess permission" do
  context "without permission" do
    let(:user) { create(:staff) }

    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_assess_permission) }

    it { is_expected.to be true }

    context "when staff is archived" do
      let(:user) { create(:staff, :with_assess_permission, archived: true) }

      it { is_expected.to be false }
    end
  end
end

RSpec.shared_examples "a policy method requiring the change email permission" do
  context "without permission" do
    let(:user) { create(:staff) }

    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_change_email_permission) }

    it { is_expected.to be true }

    context "when staff is archived" do
      let(:user) do
        create(:staff, :with_change_email_permission, archived: true)
      end

      it { is_expected.to be false }
    end
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

    context "when staff is archived" do
      let(:user) do
        create(:staff, :with_change_name_permission, archived: true)
      end

      it { is_expected.to be false }
    end
  end
end

RSpec.shared_examples "a policy method requiring the change work history permission" do
  context "without permission" do
    let(:user) { create(:staff) }

    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_change_work_history_permission) }

    it { is_expected.to be true }

    context "when staff is archived" do
      let(:user) do
        create(:staff, :with_change_work_history_permission, archived: true)
      end

      it { is_expected.to be false }
    end
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

    context "when staff is archived" do
      let(:user) do
        create(:staff, :with_reverse_decision_permission, archived: true)
      end

      it { is_expected.to be false }
    end
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

    context "when staff is archived" do
      let(:user) do
        create(:staff, :with_support_console_permission, archived: true)
      end

      it { is_expected.to be false }
    end
  end
end

RSpec.shared_examples "a policy method requiring the verify permission" do
  context "without permission" do
    let(:user) { create(:staff) }

    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_verify_permission) }

    it { is_expected.to be true }

    context "when staff is archived" do
      let(:user) { create(:staff, :with_verify_permission, archived: true) }

      it { is_expected.to be false }
    end
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

    context "when staff is archived" do
      let(:user) { create(:staff, :with_withdraw_permission, archived: true) }

      it { is_expected.to be false }
    end
  end
end

RSpec.shared_examples "a policy method requiring the manage staff permission" do
  context "without permission" do
    let(:user) { create(:staff) }

    it { is_expected.to be false }
  end

  context "with permission" do
    let(:user) { create(:staff, :with_manage_staff_permission) }

    it { is_expected.to be true }

    context "when staff is archived" do
      let(:user) do
        create(:staff, :with_manage_staff_permission, archived: true)
      end

      it { is_expected.to be false }
    end
  end
end
