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
    let(:application_form) { create(:application_form) }
    let(:params) { { id: application_form.id } }

    subject(:assessment_tasks) { view_object.assessment_tasks }

    describe "submitted details" do
      subject(:submitted_details) { assessment_tasks.fetch(:submitted_details) }

      context "with none checks" do
        before do
          application_form.update!(region: create(:region, :none_checks))
        end

        it do
          is_expected.to eq(
            %i[personal_information qualifications work_history]
          )
        end
      end

      context "with written checks" do
        before do
          application_form.update!(region: create(:region, :written_checks))
        end

        it do
          is_expected.to eq(
            %i[personal_information qualifications professional_standing]
          )
        end
      end

      context "with online checks" do
        before do
          application_form.update!(region: create(:region, :online_checks))
        end

        it do
          is_expected.to eq(
            %i[personal_information qualifications professional_standing]
          )
        end
      end
    end

    describe "recommendation" do
      subject(:recommendation) { assessment_tasks.fetch(:recommendation) }

      it { is_expected.to eq(%i[first_assessment second_assessment]) }
    end
  end

  describe "#assessment_task_path" do
    subject(:assessment_task_path) do
      view_object.assessment_task_path(section, item)
    end

    let(:application_form) { create(:application_form) }
    let(:params) { { id: application_form.id } }

    context "with submitted details section" do
      let(:section) { :submitted_details }

      context "with personal information item" do
        let(:item) { :personal_information }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/check_personal_information"
          )
        end
      end

      context "with qualifications item" do
        let(:item) { :qualifications }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/check_qualifications"
          )
        end
      end

      context "with work history item" do
        let(:item) { :work_history }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/check_work_history"
          )
        end
      end

      context "with professional standing item" do
        let(:item) { :professional_standing }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/check_professional_standing"
          )
        end
      end
    end

    context "with recommendation section" do
      let(:section) { :recommendation }
      let(:item) { nil }

      it do
        is_expected.to eq(
          "/assessor/applications/#{application_form.id}/complete-assessment"
        )
      end
    end
  end

  describe "#assessment_task_status" do
    subject(:assessment_task_status) do
      view_object.assessment_task_status(section, item)
    end

    let(:item) { nil }

    context "with submitted details section" do
      let(:section) { :submitted_details }

      it { is_expected.to eq(:in_progress) }
    end

    context "with recommendation section" do
      let(:section) { :recommendation }

      it { is_expected.to eq(:not_started) }
    end
  end
end
