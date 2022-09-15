require "rails_helper"

RSpec.describe TeacherInterface::AddAnotherUploadForm, type: :model do
  describe "validations" do
    subject(:form) { described_class.new(add_another:) }

    context "when the fields are blank" do
      let(:add_another) { "" }

      it { is_expected.to_not be_valid }
    end

    context "when the fields are true" do
      let(:add_another) { true }

      it { is_expected.to be_valid }
    end

    context "when the fields are false" do
      let(:add_another) { false }

      it { is_expected.to be_valid }
    end
  end
end
