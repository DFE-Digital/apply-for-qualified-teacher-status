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

    context "with search params" do
      let(:params) { { search: { states: %w[awarded] } } }

      it { is_expected.to eq("/assessor/applications?states%5B%5D=awarded") }
    end
  end

  describe "#assessment_tasks" do
    subject(:assessment_tasks) { view_object.assessment_tasks }

    it do
      is_expected.to eq(
        {
          submitted_details: %i[
            personal_information
            qualifications
            work_history
            professional_standing
          ],
          recommendation: %i[first_assessment second_assessment]
        }
      )
    end
  end

  describe "#assessment_task_path" do
    subject(:assessment_task_path) do
      view_object.assessment_task_path(section, item)
    end

    let(:application_form) { create(:application_form) }
    let(:params) { { id: application_form.id } }

    let(:item) { nil }

    context "with submitted details section" do
      let(:section) { :submitted_details }

      it { is_expected.to eq("#") }
    end

    context "with recommendation section" do
      let(:section) { :recommendation }

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
