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

    context "with a draft application form" do
      let(:params) { { id: create(:application_form, :draft).id } }

      it "raise an error" do
        expect { application_form }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with a submitted application form" do
      let(:params) { { id: create(:application_form, :submitted).id } }

      it { is_expected.to_not be_nil }
    end
  end

  describe "#assessment_tasks" do
    subject(:assessment_tasks) { view_object.assessment_tasks }

    let(:application_form) { create(:application_form, :submitted) }
    let(:assessment) { create(:assessment, application_form:) }
    before do
      create(:assessment_section, :personal_information, assessment:)
      create(:assessment_section, :qualifications, assessment:)
    end

    let(:params) { { id: application_form.id } }

    describe "pre-assessment tasks" do
      subject(:pre_assessment_tasks) { assessment_tasks[:pre_assessment_tasks] }

      it { is_expected.to be_nil }

      context "when teaching authority provides written statement and a professional standing request" do
        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
          create(:professional_standing_request, assessment:)
        end

        it { is_expected.to eq(%i[await_professional_standing_request]) }
      end

      context "with a preliminary check" do
        before do
          application_form.update!(requires_preliminary_check: true)
          create(:professional_standing_request, assessment:)
        end

        it { is_expected.to eq(%i[preliminary_check]) }
      end
    end

    describe "initial assessment" do
      subject(:initial_assessment) { assessment_tasks[:initial_assessment] }

      it { is_expected.to_not be_nil }

      context "with work history" do
        before { create(:assessment_section, :work_history, assessment:) }

        it do
          is_expected.to eq(
            %i[
              personal_information
              qualifications
              work_history
              initial_assessment_recommendation
            ],
          )
        end
      end

      context "with professional standing statement" do
        before do
          create(:assessment_section, :professional_standing, assessment:)
        end

        it do
          is_expected.to eq(
            %i[
              personal_information
              qualifications
              professional_standing
              initial_assessment_recommendation
            ],
          )
        end
      end
    end

    describe "further information requests" do
      subject(:further_information) do
        assessment_tasks[:further_information_requests]
      end

      it { is_expected.to be_nil }

      context "with further information" do
        before { create(:further_information_request, assessment:) }

        it { is_expected.to eq([:review_requested_information]) }
      end
    end

    describe "verification requests" do
      subject(:verification_requests) do
        assessment_tasks[:verification_requests]
      end

      it { is_expected.to be_nil }

      context "with a professional standing request" do
        before { create(:professional_standing_request, assessment:) }

        it do
          is_expected.to eq(
            %i[
              locate_professional_standing_request
              review_professional_standing_request
              assessment_recommendation
            ],
          )
        end
      end

      context "with a qualification request" do
        before { create(:qualification_request, assessment:) }

        it do
          is_expected.to eq(
            %i[qualification_requests assessment_recommendation],
          )
        end
      end

      context "with a reference request" do
        before { create(:reference_request, assessment:) }

        it do
          is_expected.to eq(%i[reference_requests assessment_recommendation])
        end
      end
    end
  end

  describe "#assessment_task_path" do
    subject(:assessment_task_path) do
      view_object.assessment_task_path(section, item, index)
    end

    let(:application_form) { create(:application_form, :submitted) }
    let!(:assessment) { create(:assessment, application_form:) }

    let(:params) { { id: application_form.id } }

    let(:index) { 0 }

    context "with pre-assessment tasks section" do
      let(:section) { :pre_assessment_tasks }
      let(:item) { :professional_standing }

      it do
        is_expected.to eq(
          "/assessor/applications/#{application_form.id}" \
            "/assessments/#{assessment.id}/professional-standing-request/location",
        )
      end
    end

    context "with initial assessment section" do
      let(:section) { :initial_assessment }

      context "and personal information" do
        let(:item) { :personal_information }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}/sections/personal_information",
          )
        end
      end

      context "and assessment recommendation" do
        let(:item) { :initial_assessment_recommendation }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}/edit",
          )
        end
      end
    end

    context "with further_information_requests section" do
      let(:section) { :further_information_requests }
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

    context "with verification_requests section" do
      let(:section) { :verification_requests }

      context "with record qualification requests item" do
        let(:item) { :qualification_requests }

        before { application_form.update!(waiting_on_qualification: true) }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}" \
              "/qualification-requests",
          )
        end
      end

      context "with reference requests item" do
        let(:item) { :reference_requests }

        before { application_form.update!(waiting_on_reference: true) }

        it do
          is_expected.to eq(
            "/assessor/applications/#{application_form.id}/assessments/#{assessment.id}" \
              "/reference-requests",
          )
        end
      end
    end
  end

  describe "#assessment_task_status" do
    let(:application_form) { create(:application_form, :submitted) }
    let(:assessment) { create(:assessment, application_form:) }
    let!(:assessment_section) do
      create(:assessment_section, :personal_information, assessment:)
    end

    let(:params) { { id: application_form.id } }

    subject(:assessment_task_status) do
      view_object.assessment_task_status(section, item, index)
    end

    let(:index) { 0 }

    context "with pre-assessment tasks section" do
      let(:section) { :pre_assessment_tasks }

      context "await professional standing request" do
        let(:item) { :await_professional_standing_request }

        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
          create(:professional_standing_request, assessment:)
        end

        it { is_expected.to eq(:waiting_on) }

        context "and professional standing request received" do
          before do
            assessment.professional_standing_request.update!(
              state: "received",
              received_at: 1.day.ago,
              location_note: "wat",
            )
          end

          it { is_expected.to eq(:completed) }
        end

        context "when preliminary check is required" do
          before do
            create(:professional_standing_request, assessment:)
            application_form.update!(requires_preliminary_check: true)
          end

          it { is_expected.to eq(:cannot_start) }
        end
      end

      context "with preliminary check" do
        let(:item) { :preliminary_check }

        before { application_form.update!(requires_preliminary_check: true) }

        context "when the check hasn't been completed" do
          before do
            application_form.assessment.update!(preliminary_check_complete: nil)
          end

          it { is_expected.to eq(:not_started) }
        end

        context "when the check has been completed" do
          before do
            application_form.assessment.update!(
              preliminary_check_complete: true,
            )
          end

          it { is_expected.to eq(:completed) }
        end

        context "when the check has been declined" do
          before do
            application_form.assessment.update!(
              preliminary_check_complete: false,
            )
          end

          it { is_expected.to eq(:completed) }
        end
      end
    end

    context "with initial assessment section" do
      let(:section) { :initial_assessment }

      context "personal information" do
        let(:item) { :personal_information }

        it { is_expected.to eq(:not_started) }
      end

      context "assessment recommendation" do
        let(:item) { :initial_assessment_recommendation }

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
            before do
              assessment.request_further_information!
              create(
                :selected_failure_reason,
                :fi_requestable,
                assessment_section:,
              )
              assessment_section.reload.update!(passed: false)
            end

            it { is_expected.to eq(:in_progress) }

            context "and further information requested" do
              before { create(:further_information_request, assessment:) }
              it { is_expected.to eq(:completed) }
            end
          end
        end
      end
    end

    context "with further_information_requests section" do
      let(:section) { :further_information_requests }
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

    context "with verification requests section" do
      let(:section) { :verification_requests }
      let(:item) { :assessment_recommendation }

      it { is_expected.to eq(:cannot_start) }

      context "when decline-able" do
        before do
          assessment.request_further_information!
          create(:further_information_request, :received, :failed, assessment:)
        end

        it { is_expected.to eq(:not_started) }
      end

      context "with an award recommendation" do
        before { assessment.award! }
        it { is_expected.to eq(:completed) }
      end

      context "with a decline recommendation" do
        before { assessment.award! }
        it { is_expected.to eq(:completed) }
      end
    end
  end
end
