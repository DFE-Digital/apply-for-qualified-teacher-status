# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationRequestsViewObject do
  subject(:view_object) { described_class.new(application_form:) }

  let(:application_form) do
    create(
      :application_form,
      :verification_stage,
      :with_assessment,
      :with_teaching_qualification,
    )
  end

  let(:assessment) { application_form.assessment }
  let(:qualification) { application_form.qualifications.first }

  let!(:qualification_request) do
    create(:qualification_request, assessment:, qualification:)
  end

  describe "#all_task_items" do
    subject(:all_task_items) { view_object.all_task_items }

    it do
      is_expected.to eq(
        [
          {
            name: "Check and select consent method",
            link: [
              :consent_methods,
              :assessor_interface,
              application_form,
              assessment,
              :qualification_requests,
            ],
            status: "not_started",
          },
        ],
      )
    end

    context "when consent methods are chosen" do
      before { qualification_request.consent_method_unsigned! }

      it do
        is_expected.to eq(
          [
            {
              name: "Check and select consent method",
              link: [
                :check_consent_methods,
                :assessor_interface,
                application_form,
                assessment,
                :qualification_requests,
              ],
              status: "completed",
            },
            {
              name: "Generate consent document",
              link: [
                :unsigned_consent_document,
                :assessor_interface,
                application_form,
                assessment,
                :qualification_requests,
              ],
              status: "not_started",
            },
            {
              name: "Request Ecctis verification",
              link: "#",
              status: "cannot_start",
            },
            {
              name: "Record Ecctis response",
              link: "#",
              status: "cannot_start",
            },
          ],
        )
      end
    end
  end

  describe "#show_individual_task_items?" do
    subject(:show_individual_task_items?) do
      view_object.show_individual_task_items?
    end

    it { is_expected.to be false }

    context "with more than one qualification request" do
      before do
        qualification_request.consent_method_unsigned!
        create(
          :qualification_request,
          assessment: application_form.assessment,
          consent_method: "unsigned",
          qualification: create(:qualification, application_form:),
        )
      end

      it { is_expected.to be true }
    end
  end

  describe "#individual_task_items_for" do
    subject(:individual_task_items_for) do
      view_object.individual_task_items_for(qualification_request:)
    end

    it { is_expected.to be_empty }

    context "when unsigned consent method" do
      before { qualification_request.consent_method_unsigned! }

      it do
        is_expected.to eq(
          [
            {
              name: "Generate consent document",
              link: [
                :unsigned_consent_document,
                :assessor_interface,
                application_form,
                assessment,
                :qualification_requests,
              ],
              status: "not_started",
            },
            {
              name: "Request Ecctis verification",
              link: "#",
              status: "cannot_start",
            },
            {
              name: "Record Ecctis response",
              link: "#",
              status: "cannot_start",
            },
          ],
        )
      end
    end

    context "when signed consent method" do
      before { qualification_request.consent_method_signed_ecctis! }

      let!(:consent_request) do
        create(:consent_request, assessment:, qualification:)
      end

      it do
        is_expected.to eq(
          [
            {
              name: "Upload consent document",
              link: [
                :check_upload,
                :assessor_interface,
                application_form,
                assessment,
                consent_request,
              ],
              status: "not_started",
            },
            {
              name: "Send consent document to applicant",
              link: nil,
              status: "cannot_start",
            },
            {
              name: "Record applicant response",
              link: "#",
              status: "cannot_start",
            },
            {
              name: "Request Ecctis verification",
              link: "#",
              status: "cannot_start",
            },
            {
              name: "Record Ecctis response",
              link: "#",
              status: "cannot_start",
            },
          ],
        )
      end
    end
  end
end
