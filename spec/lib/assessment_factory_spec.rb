# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessmentFactory do
  let(:application_form) { create(:application_form) }

  describe "#call" do
    subject(:call) { described_class.call(application_form:) }

    it "creates an assessment" do
      expect { call }.to change(Assessment, :count).by(1)
    end

    it "sets the fields" do
      assessment = call
      expect(assessment.unknown?).to be true
      expect(assessment.application_form).to eq(application_form)
    end

    describe "sections" do
      subject(:sections) { call.sections }

      it "creates two assessments" do
        expect(sections.count).to eq(2)
      end

      it "creates a personal information assessment" do
        expect(sections.personal_information.count).to eq(1)
      end

      it "creates a qualifications assessment" do
        expect(sections.qualifications.count).to eq(1)
      end

      context "with work history" do
        before { application_form.needs_work_history = true }

        it "creates a work history assessment" do
          expect(sections.work_history.count).to eq(1)
        end
      end

      context "with written statement" do
        before { application_form.needs_written_statement = true }

        it "creates a professional standing assessment" do
          expect(sections.professional_standing.count).to eq(1)
        end
      end

      context "with registration number" do
        before { application_form.needs_registration_number = true }

        it "creates a professional standing assessment" do
          expect(sections.professional_standing.count).to eq(1)
        end
      end
    end
  end
end
