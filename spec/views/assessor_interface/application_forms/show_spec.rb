# frozen_string_literal: true

require "rails_helper"

RSpec.describe "assessor_interface/application_forms/show.html.erb",
               type: :view do
  subject(:back_link_url) do
    render
    view.content_for(:back_link_url)
  end

  let(:application_form) do
    create(:application_form, :submitted, :with_assessment)
  end
  let(:current_staff) { create(:staff) }
  let(:previous_path) { nil }

  before do
    assign(
      :view_object,
      AssessorInterface::ApplicationFormsShowViewObject.new(
        params:
          ActionController::Parameters.new(
            reference: application_form.reference,
          ),
        current_staff:,
      ),
    )
    allow(view).to receive(:current_staff).and_return(current_staff)

    session[:history_stack] = [
      ({ path: previous_path, origin: true, check: false } if previous_path),
      {
        path: assessor_interface_application_form_path(application_form),
        origin: true,
        check: false,
      },
    ].compact
  end

  describe "back link" do
    %w[
      /assessor/applications
      /assessor/applications?page=2
      /assessor/applications/123456
      /assessor/applications/654321
      /assessor/applications/123456?highlight_email=true
      /assessor/applications/123456/assessments/1/sections/2
      /assessor/applications/123456/assessments/1/consent-requests/2/verify
    ].each do |path|
      context "when the previous path is #{path}" do
        let(:previous_path) { path }

        it { is_expected.to eq(assessor_interface_application_forms_path) }
      end
    end

    [
      nil,
      "/assessor/service-level-agreements?sla=40",
      "/assessor/applications-export",
    ].each do |path|
      context "when the previous path is #{path.inspect}" do
        let(:previous_path) { path }

        it do
          expect(back_link_url).to eq(
            back_history_path(
              default: assessor_interface_application_forms_path,
            ),
          )
        end
      end
    end

    context "when the previous page is the current application's overview" do
      let(:previous_path) do
        assessor_interface_application_form_path(application_form)
      end

      it { is_expected.to eq(assessor_interface_application_forms_path) }
    end

    it "does not pop history when rendering" do
      expect { back_link_url }.not_to(change { session[:history_stack] })
    end
  end
end
