# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsShowViewObject do
  subject(:view_object) do
    described_class.new(params: ActionController::Parameters.new(params))
  end

  let(:params) { {} }

  describe "#application_form" do
    subject(:application_form) { view_object.application_form }

    it "raise an error" do
      expect { application_form }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "with an application form" do
      let(:params) { { id: create(:application_form).id } }

      it { is_expected.to_not be_nil }
    end
  end

  describe "#back_link_path" do
    subject(:back_link_path) { view_object.back_link_path }

    it { is_expected.to eq("/assessor/applications") }

    context "with form params" do
      let(:params) { { search: { states: %w[awarded] } } }

      it { is_expected.to eq("/assessor/applications?states%5B%5D=awarded") }
    end
  end

  describe "#assessment_tasks" do
    subject(:assessment_tasks) { view_object.assessment_tasks }

    let(:application_form) { create(:application_form) }
    let(:assessment) { create(:assessment, application_form:) }
    before do
      create(:assessment_section, :personal_information, assessment:)
      create(:assessment_section, :qualifications, assessment:)
    end

    let(:params) { { id: application_form.id } }

    describe "submitted details" do
      subject(:submitted_details) { assessment_tasks.fetch(:submitted_details) }

      context "with work history" do
        before { create(:assessment_section, :work_history, assessment:) }

        it do
          is_expected.to eq(
            %i[personal_information qualifications work_history],
          )
        end
      end

      context "with professional standing statement" do
        before do
          create(:assessment_section, :professional_standing, assessment:)
        end

        it do
          is_expected.to eq(
            %i[personal_information qualifications professional_standing],
          )
        end
      end
    end

    describe "recommendation" do
      subject(:recommendation) { assessment_tasks.fetch(:recommendation) }

      it { is_expected.to eq(%i[initial_assessment]) }
    end

    describe "further_information" do
      subject(:further_information) { assessment_tasks[:further_information] }

      it { is_expected.to be_nil }

      context "with further information" do
        before { create(:further_information_request, assessment:) }

        it { is_expected.to eq([:review_requested_information]) }
      end
    end
  end

  describe "#assessment_task_path" do
    subject(:assessment_task_path) do
      view_object.assessment_task_path(section, item, index)
    end

    let(:application_form) { create(:application_form) }
    let!(:assessment) { create(:assessment, application_form:) }

    let(:params) { { id: application_form.id } }

    let(:index) { 0 }

    context "with submitted details section" do
      let(:section) { :submitted_details }
      let(:item) { :personal_information }

      it do
        is_expected.to eq(
          "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}/sections/personal_information",
        )
      end
    end

    context "with recommendation section" do
      let(:section) { :recommendation }
      let(:item) { :initial_assessment }

      it do
        is_expected.to eq(
          "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}/edit",
        )
      end
    end

    context "with further_information section" do
      let(:section) { :further_information }
      let(:item) { :review_requested_information }

      let!(:further_information_request) do
        create(:further_information_request, assessment:)
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#assessment_task_status" do
    let(:application_form) { create(:application_form) }
    let(:assessment) { create(:assessment, application_form:) }
    let!(:assessment_section) do
      create(:assessment_section, :personal_information, assessment:)
    end

    let(:params) { { id: application_form.id } }

    subject(:assessment_task_status) do
      view_object.assessment_task_status(section, item, index)
    end

    let(:index) { 0 }

    context "with submitted details section" do
      let(:section) { :submitted_details }
      let(:item) { :personal_information }

      it { is_expected.to eq(:not_started) }
    end

    context "with recommendation section" do
      let(:section) { :recommendation }
      let(:item) { :initial_assessment }

      context "with unfinished assessment sections" do
        it { is_expected.to eq(:cannot_start_yet) }
      end

      context "with finished assessment sections" do
        before { assessment_section.update!(passed: true) }
        it { is_expected.to eq(:not_started) }

        context "with a finished assessment" do
          before { assessment.award! }
          it { is_expected.to eq(:completed) }
        end

        context "with further information request" do
          before { create(:further_information_request, assessment:) }

          it { is_expected.to eq(:further_information_requested) }
        end
      end
    end

    context "with further_information section" do
      let(:section) { :further_information }
      let(:item) { :review_requested_information }

      before { create(:further_information_request, assessment:) }

      it { is_expected.to eq(:requested) }
    end
  end
end
