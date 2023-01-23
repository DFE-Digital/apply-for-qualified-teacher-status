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

  describe "#assessment_tasks" do
    subject(:assessment_tasks) { view_object.assessment_tasks }

    let(:application_form) { create(:application_form) }
    let(:assessment) { create(:assessment, application_form:) }
    before do
      create(:assessment_section, :personal_information, assessment:)
      create(:assessment_section, :qualifications, assessment:)
    end

    let(:params) { { id: application_form.id } }

    describe "pre-assessment tasks" do
      subject(:pre_assessment_tasks) { assessment_tasks[:pre_assessment_tasks] }

      it { is_expected.to be_nil }

      context "with a professional standing request" do
        before { create(:professional_standing_request, assessment:) }

        it { is_expected.to eq(%i[professional_standing_request]) }
      end
    end

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

    context "with pre-assessment tasks section" do
      let(:section) { :pre_assessment_tasks }
      let(:item) { :professional_standing }

      it do
        is_expected.to eq(
          "/assessor/applications/#{application_form.id}/professional-standing-request/edit",
        )
      end
    end

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

      context "and initial assessment" do
        let(:item) { :initial_assessment }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}/edit",
          )
        end
      end
    end

    context "with further_information section" do
      let(:section) { :further_information }
      let(:item) { :review_requested_information }

      context "and a requested further information request" do
        let!(:further_information_request) do
          create(:further_information_request, :requested, assessment:)
        end
        it { is_expected.to be_nil }
      end

      context "and a received further information request" do
        let!(:further_information_request) do
          create(:further_information_request, :received, assessment:)
        end
        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}" \
              "/further-information-requests/#{further_information_request.id}/edit",
          )
        end
      end
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

      context "initial assessment" do
        let(:item) { :initial_assessment }

        context "with unfinished assessment sections" do
          it { is_expected.to eq(:cannot_start) }
        end

        context "with finished assessment sections" do
          before { assessment_section.update!(passed: true) }
          it { is_expected.to eq(:not_started) }

          context "and award" do
            before { assessment.award! }
            it { is_expected.to eq(:completed) }
          end

          context "and decline" do
            before { assessment.decline! }
            it { is_expected.to eq(:completed) }
          end

          context "and request further information" do
            before { assessment.request_further_information! }
            it { is_expected.to eq(:in_progress) }

            context "and further information requested" do
              before { create(:further_information_request, assessment:) }
              it { is_expected.to eq(:completed) }
            end
          end
        end
      end
    end

    context "with further_information section" do
      let(:section) { :further_information }
      let(:item) { :review_requested_information }

      before { assessment.request_further_information! }

      context "and a requested further information request" do
        before { create(:further_information_request, :requested, assessment:) }
        it { is_expected.to eq(:cannot_start) }
      end

      context "and a received further information request" do
        before { create(:further_information_request, :received, assessment:) }
        it { is_expected.to eq(:not_started) }
      end

      context "and a passed further information request" do
        before do
          create(:further_information_request, :received, :passed, assessment:)
        end
        it { is_expected.to eq(:in_progress) }
      end

      context "and a failed further information request" do
        before do
          create(:further_information_request, :received, :failed, assessment:)
        end
        it { is_expected.to eq(:in_progress) }
      end

      context "and a passed further information request with finished assessment" do
        before do
          assessment.award!
          create(:further_information_request, :received, :passed, assessment:)
        end
        it { is_expected.to eq(:completed) }
      end

      context "and a failed further information request" do
        before do
          assessment.decline!
          create(:further_information_request, :received, :failed, assessment:)
        end
        it { is_expected.to eq(:completed) }
      end
    end
  end
end
