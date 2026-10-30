# frozen_string_literal: true

require "rails_helper"

RSpec.describe QualificationHelper do
  describe "#qualification_title" do
    subject(:title) { qualification_title(qualification) }

    let(:qualification) { build(:qualification) }

    it { is_expected.to eq("Teaching qualification") }

    context "when the qualification is an additional qualification" do
      let(:application_form) { create(:application_form) }
      let(:qualification) { create(:qualification, application_form:) }

      before { create_list(:qualification, 2, application_form:) }

      it { is_expected.to eq("Additional qualification") }
    end

    context "with a title" do
      before { qualification.title = "Title" }

      it { is_expected.to eq("Title") }

      context "with an institution name" do
        before { qualification.institution_name = "Example University" }

        it { is_expected.to eq("Title (Example University)") }
      end
    end

    context "with an institution name" do
      before { qualification.institution_name = "Name" }

      it { is_expected.to eq("Name") }
    end
  end
end
