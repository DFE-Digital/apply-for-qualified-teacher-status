# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::QualificationViewObject do
  subject(:view_object) { described_class.new(qualification:) }

  let(:qualification) { create(:qualification) }

  describe "#qualifications_information" do
    let(:info) { "Qualifications info" }

    context "when country has qualifications information" do
      it "returns qualifications info for the country" do
        qualification.application_form.region.country.update!(
          qualifications_information: info,
        )
        expect(view_object.qualifications_information).to eq(info)
      end
    end

    context "when region has qualifications information" do
      it "returns qualifications info for the country" do
        qualification.application_form.region.country.update!(
          qualifications_information: "Country specific info",
        )
        qualification.application_form.region.update!(
          qualifications_information: info,
        )
        expect(view_object.qualifications_information).to eq(info)
      end
    end

    context "with no qualifications information" do
      it "returns blank" do
        expect(view_object.qualifications_information).to be_blank
      end
    end
  end
end
