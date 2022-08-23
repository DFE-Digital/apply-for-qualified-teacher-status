RSpec.describe TeacherInterface::HasWorkHistoryForm, type: :model do
  subject(:has_work_history_form) do
    described_class.new(application_form:, has_work_history:)
  end

  let(:application_form) { build(:application_form) }
  let(:has_work_history) { nil }

  it { is_expected.to validate_presence_of(:application_form) }

  describe "#valid?" do
    subject(:valid?) { has_work_history_form.valid? }

    context "with a blank value" do
      let(:has_work_history) { "" }

      it { is_expected.to be true }
    end

    context "with a true value" do
      let(:has_work_history) { "true" }

      it { is_expected.to be true }
    end

    context "with a false value" do
      let(:has_work_history) { "false" }

      it { is_expected.to be true }
    end
  end

  describe "#save" do
    subject(:has_work_history_value) { application_form.has_work_history }

    before { has_work_history_form.save }

    context "with a blank value" do
      let(:has_work_history) { "" }

      it { is_expected.to be_nil }
    end

    context "with a true value" do
      let(:has_work_history) { "true" }

      it { is_expected.to be true }
    end

    context "with a false value" do
      let(:has_work_history) { "false" }

      it { is_expected.to be false }
    end
  end
end
