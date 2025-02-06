# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::PersonalInformationViewObject do
  subject(:view_object) { described_class.new(application_form:) }

  let(:requires_passport_as_identity_proof) { false }
  let(:application_form) do
    create(:application_form, requires_passport_as_identity_proof:)
  end

  describe "#alternative_name_legend" do
    it "returns the content with ID documents" do
      expect(view_object.alternative_name_legend).to eq(
        "Does your name appear differently on your ID documents or qualifications?",
      )
    end

    context "when the application form requires passport upload" do
      let(:requires_passport_as_identity_proof) { true }

      it "returns the content with passport" do
        expect(view_object.alternative_name_legend).to eq(
          "Does your name appear differently on your passport or qualifications?",
        )
      end
    end
  end

  describe "#alternative_name_hint" do
    it "returns the content with ID documents" do
      expect(view_object.alternative_name_hint).to eq(
        "If your name appears differently on your ID documents or qualifications you" \
          " need to upload proof of your name change, for example, your marriage or civil partnership certificate.",
      )
    end

    context "when the application form requires passport upload" do
      let(:requires_passport_as_identity_proof) { true }

      it "returns the content with passport" do
        expect(view_object.alternative_name_hint).to eq(
          "If your name appears differently on your passport or qualifications you" \
            " need to upload proof of your name change, for example, your marriage or civil partnership certificate.",
        )
      end
    end
  end
end
