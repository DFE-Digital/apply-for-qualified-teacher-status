require "rails_helper"

RSpec.describe QualificationHelper do
  describe "#qualification_title" do
    subject(:title) { qualification_title(qualification) }

    let(:qualification) { build(:qualification) }

    it { is_expected.to eq("Teaching qualification") }

    context "with a title" do
      before { qualification.title = "Title" }

      it { is_expected.to eq("Title") }
    end

    context "with an institution name" do
      before { qualification.institution_name = "Name" }

      it { is_expected.to eq("Name") }
    end

    context "with an institution country" do
      before { qualification.institution_country_code = "FR" }

      it { is_expected.to eq("France") }
    end
  end
end
